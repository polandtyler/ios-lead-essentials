//
//  CacheFeedUseCaseTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 11/26/23.
//

import XCTest
import EssentialDev_FeedProject

class FeedStore {
	var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
	var store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(items: [FeedItem]) {
		store.deleteCachedFeedCallCount += 1
	}
}

final class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doeNotDeleteCacheUponCreation() {
		let store = FeedStore()
		let _ = LocalFeedLoader(store: store)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDeletion() {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		
		sut.save(items: uniqueItems())
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	// MARK: - Helpers
	private func uniqueItems() -> [FeedItem] {
		return [
			FeedItem(id: UUID(),
						description: "",
						location: nil,
						imageURL: URL(string: "http://a-url.com")!)
			]
	}

}
