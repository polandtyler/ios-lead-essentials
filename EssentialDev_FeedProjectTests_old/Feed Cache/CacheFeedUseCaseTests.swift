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
	
	func deleteCachedFeed() {
		deleteCachedFeedCallCount += 1
	}
}

class LocalFeedLoader {
	private let store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(items: [FeedItem]) {
		store.deleteCachedFeed()
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
						imageURL: anyURL())
			]
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func badURL() -> URL {
		return URL(string: "malformed url")!
	}

}
