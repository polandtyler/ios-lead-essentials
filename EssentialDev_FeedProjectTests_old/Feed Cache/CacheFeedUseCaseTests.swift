//
//  CacheFeedUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 11/26/23.
//

import XCTest

class FeedStore {
	var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
	var store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
}

final class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doeNotDeleteCacheUponCreation() {
		let store = FeedStore()
		let _ = LocalFeedLoader(store: store)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}

}
