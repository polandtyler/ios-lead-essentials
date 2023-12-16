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
		let exp = expectation(description: "Wait for load completion")
		
		var receivedError: Error?
		sut.load() { result in
			switch result {
			case let .failure(error):
				receivedError = error
			default:
				XCTFail("Expected failure, got \(result) instead")
			}
			exp.fulfill()
		}
		
		store.completeRetrieval(with: retrievalError)
		wait(for: [exp])
		
		XCTAssertEqual(receivedError as NSError?, retrievalError)
	}
	
	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()
		let exp = expectation(description: "Wait for load completion")
		
		var receivedImages = [FeedImage]()
		sut.load() { result in
			switch result {
			case let .success(images):
				receivedImages = images
			default:
				XCTFail("Expected empty array of images but got \(result) instead")
			}
			exp.fulfill()
		}
		
		store.completeRetrievalWithEmptyCache()
		wait(for: [exp])
		
		XCTAssertEqual(receivedImages, [])
	}
	
	// MARK: - HELPERS
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
}
