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
		
		sut.load()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	// MARK: - HELPERS
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
}
