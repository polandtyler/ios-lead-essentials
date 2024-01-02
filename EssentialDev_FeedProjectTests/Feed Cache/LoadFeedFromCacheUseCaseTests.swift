//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 12/14/23.
//

import XCTest
import EssentialDev_FeedProject

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
	
	func test_init_doeNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()
		
		sut.load() { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_failsOnRetrievalError() {
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()
		
		expect(sut, toCompleteWith: .failure(retrievalError)) {
			store.completeRetrieval(with: retrievalError)
		}
	}
	
	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrievalWithEmptyCache()
		}
	}
	
	func test_load_deliversCachedImagesOnLessThan7DaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		
		expect(sut, toCompleteWith: .success(feed.models)) {
			store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
		}
	}
	
	func test_load_deliversNoImagesOn7DayOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		
		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: [], timestamp: sevenDayOldTimestamp)
		}
	}
	
	func test_load_deliversNoImagesOnMoreThan7DayOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
		
		expect(sut, toCompleteWith: .success([])) {
			store.completeRetrieval(with: [], timestamp: sevenDayOldTimestamp)
		}
	}
	
	func test_load_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		sut.load { _ in }
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_load_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.load { _ in }
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_doesNotDeleteCacheOnLessThanSevenDayOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT()
		
		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDayOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_deletesCacheOnSevenDayOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT()
		
		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: sevenDayOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	// completes date triangulation
	func test_load_deletesCacheOnMoreThanSevenDayOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT()
		
		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDayOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	// MARK: - HELPERS
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
				
			case let (.success(receivedImages), .success(expectedImages)):
				XCTAssertEqual(receivedImages, expectedImages)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError)
				
			default:
				XCTFail("Expected \(expectedResult), but got \(receivedResult) instead.")
				
			}
			
			exp.fulfill()
		}
		
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
		let models = [uniqueImage(), uniqueImage()]
		let local = models.map(localFeedItem(from:))
		return (models, local)
	}
	
	private func emptyUniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
		return ([], [])
	}
	
	private func uniqueImage() -> FeedImage {
		return FeedImage(id: UUID(),
						 description: "",
						 location: nil,
						 url: anyURL())
	}
	
	private func localFeedItem(from item: FeedImage) -> LocalFeedImage {
		LocalFeedImage(id: item.id, description: item.description, location: item.location, url: item.url)
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: Date())!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
