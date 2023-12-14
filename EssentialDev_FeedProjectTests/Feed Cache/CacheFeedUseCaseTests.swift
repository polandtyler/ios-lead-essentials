//
//  CacheFeedUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 11/26/23.
//

import XCTest
import EssentialDev_FeedProject

final class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_doeNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_save_requestsCacheDeletion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items: items) { _ in }
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		sut.save(items: items) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let items = [uniqueItem(), uniqueItem()]
		let localItems = items.map(localFeedItem(from:))
		let (sut, store) = makeSUT(currentDate: { timestamp })
		
		sut.save(items: items) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(localItems, timestamp)])
	}
	
	func test_save_failsOnDeletionError() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		let exp = expectation(description: "Wait for save completion")
		
		var receivedError: Error?
		sut.save(items: items) { error in
			receivedError = error
			exp.fulfill()
		}
		
		store.completeDeletion(with: deletionError)
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, deletionError)
	}
	
	func test_save_failsOnInsertionError() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		let exp = expectation(description: "Wait for save completion")
		
		var receivedError: Error?
		sut.save(items: items) { error in
			receivedError = error
			exp.fulfill()
		}
		
		store.completeDeletionSuccessfully()
		store.completeInsertion(with: insertionError)
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, insertionError)
	}
	
	func test_succeeds_onSuccessfulCacheInsertion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		let exp = expectation(description: "Wait for save completion")
		
		var receivedError: Error?
		sut.save(items: items) { error in
			receivedError = error
			exp.fulfill()
		}
		
		store.completeDeletionSuccessfully()
		store.completeInsertionSuccessfully()
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertNil(receivedError)
	}
	
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [LocalFeedLoader.SaveResult]()
		sut?.save(items: [uniqueItem()], completion: {
			receivedResults.append($0)
		})
		sut = nil
		store.completeDeletion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		var receivedResults = [Error?]()
		sut?.save(items: [uniqueItem()], completion: {
			receivedResults.append($0)
		})
		
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for save completion")
		
		var receivedError: Error?
		sut.save(items: [uniqueItem()]) { error in
			receivedError = error
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
	
	private class FeedStoreSpy: FeedStore {
		enum ReceivedMessage: Equatable {
			case deleteCachedFeed
			case insert([LocalFeedItem], Date)
		}
		
		private(set) var receivedMessages = [ReceivedMessage]()
		
		private var deletionCompletions = [DeletionCompletion]()
		private var insertionCompletions = [InsertionCompletion]()
		
		func deleteCachedFeed(completion: @escaping DeletionCompletion) {
			deletionCompletions.append(completion)
			receivedMessages.append(.deleteCachedFeed)
		}
		
		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}
		
		func completeDeletionSuccessfully(at index: Int = 0) {
			deletionCompletions[index](nil)
		}
		
		func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(items, timestamp))
		}
		
		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}
	}
	
	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(),
						description: "",
						location: nil,
						imageURL: anyURL())
	}
	
	private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
		let models = [uniqueItem(), uniqueItem()]
		let local = models.map(localFeedItem(from:))
		return (models, local)
	}
	
	private func localFeedItem(from item: FeedItem) -> LocalFeedItem {
		LocalFeedItem(id: item.id, description: item.description, location: item.location, imageURL: item.imageURL)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
}
