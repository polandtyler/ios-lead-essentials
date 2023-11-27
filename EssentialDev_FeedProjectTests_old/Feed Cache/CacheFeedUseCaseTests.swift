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
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestsCacheDeletion() {
		let items = [uniqueItem(), uniqueItem()]
		let (sut, store) = makeSUT()
		
		sut.save(items: items)
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		
		
		return (LocalFeedLoader(store: store), store)
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
	
	private func badURL() -> URL {
		return URL(string: "malformed url")!
	}

}
