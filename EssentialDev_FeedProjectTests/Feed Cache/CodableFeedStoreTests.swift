//
//  CodableFeedStoreTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 1/9/24.
//

import XCTest
import EssentialDev_FeedProject

typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
typealias InsertionCompletion = (Error?) -> Void
class CodableFeedStore {
	
	private struct Cache: Codable {
		let feed: [LocalFeedImage]
		let timestamp: Date
	}
	
	private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			completion(.empty)
			return
		}
		
		let decoder = JSONDecoder()
		let cache = try! decoder.decode(Cache.self, from: data)
		completion(.found(feed: cache.feed, timestamp: cache.timestamp))
		
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let encoder = JSONEncoder()
		let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
		try! encoded.write(to: storeURL)
		completion(nil)
	}
}

final class CodableFeedStoreTests: XCTestCase {
	
	override class func setUp() {
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}
	
	override class func tearDown() {
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
		try? FileManager.default.removeItem(at: storeURL)
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let (_, sut) = makeSUT()
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { result in
			switch result {
			case .empty:
				break
			default:
				XCTFail("Expected empty result but got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let (_, sut) = makeSUT()
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { firstResult in
			sut.retrieve { secondResult in
				switch (firstResult, secondResult) {
				case (.empty, .empty):
					break
				default:
					XCTFail("Expected empty result but got \(firstResult) and \(secondResult) instead")
				}
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
		let (_, sut) = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.insert(feed, timestamp: timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			sut.retrieve { retrieveResult in
				switch retrieveResult {
				case let .found(feed: retrievedFeed, timestamp: retrievedTimestamp):
					XCTAssertEqual(retrievedFeed, feed)
					XCTAssertEqual(retrievedTimestamp, timestamp)
				default:
					XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp) but got \(retrieveResult) instead")
				}
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	
	private func makeSUT() -> (Any?, CodableFeedStore) {
		let sut = CodableFeedStore()
		return (nil, sut)
	}

}
