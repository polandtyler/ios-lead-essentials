//
//  CodableFeedStoreTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 1/9/24.
//

import XCTest
import EssentialDev_FeedProject

typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
class CodableFeedStore {
	func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}

final class CodableFeedStoreTests: XCTestCase {

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
	
	
	private func makeSUT() -> (Any?, CodableFeedStore) {
		let sut = CodableFeedStore()
		return (nil, sut)
	}

}
