//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 1/2/24.
//

import XCTest
import EssentialDev_FeedProject

final class ValidateFeedCacheUseCaseTests: XCTestCase {

	func test_init_doeNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validate_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrievalWithEmptyCache()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validate_doesNotDeleteNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let unexpiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: unexpiredCacheTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_validate_deletesCacheOnExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiringCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: expiringCacheTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validate_deletesExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDayOldTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT()
		
		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDayOldTimestamp)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}
	
	func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
		
		sut?.validateCache()
		sut = nil
		store.completeRetrieval(with: anyNSError())
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	// MARK: - HELPERS
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, 
						 file: StaticString = #file,
						 line: UInt = #line
	) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
}
