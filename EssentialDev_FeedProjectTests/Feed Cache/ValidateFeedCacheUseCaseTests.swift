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
