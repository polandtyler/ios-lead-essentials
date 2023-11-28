//
//  CacheFeedUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 11/26/23.
//

import XCTest
import EssentialDev_FeedProject

class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void

	var deleteCachedFeedCallCount: Int = 0
	var insertCallCount: Int = 0
	
	private var deletionCompletions = [DeletionCompletion]()
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deleteCachedFeedCallCount += 1
		deletionCompletions.append(completion)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	func insert(_ items: [FeedItem]) {
		insertCallCount += 1
	}
}

class LocalFeedLoader {
	private let store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(items: [FeedItem]) {
		store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				store.insert(items)
			}
		}
	}
}

final class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doeNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDeletion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items: items)
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		sut.save(items: items)
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.insertCallCount, 0)
	}
	
	func test_save_requestsNewCacheInsertionOnDeletion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items: items)
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.insertCallCount, 1)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(),
						description: "",
						location: nil,
						imageURL: anyURL())
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}

}
