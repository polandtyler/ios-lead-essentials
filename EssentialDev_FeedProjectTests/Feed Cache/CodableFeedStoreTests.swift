//
//  CodableFeedStoreTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 1/9/24.
//

import XCTest
import EssentialDev_FeedProject

class CodableFeedStoreTests: XCTestCase, FailableRetrieveFeedStoreSpecs, FailableInsertFeedStoreSpecs, FailableDeleteFeedStoreSpecs {

	override func setUp() {
		super.setUp()
		
		setupEmptyStoreState()
	}
	
	override func tearDown() {
		super.tearDown()
		
		undoStoreSideEffects()
	}
	
	// MARK: Retrieve
	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .empty)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		// FIXME: fails - when run in isolation its ok
		/*
		 failed - Expected to retrieve found(feed: [EssentialDev_FeedProject.LocalFeedImage(id: 606B1CB1-1561-4E70-ACDA-4E51F55A7B3E, description: Optional(""), location: nil, url: http://any-url.com), EssentialDev_FeedProject.LocalFeedImage(id: 9A311B3C-2E50-447B-B3D2-B4E6963378A3, description: Optional(""), location: nil, url: http://any-url.com)], timestamp: 2024-03-23 19:33:26 +0000), got empty instead
		 */
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		// FIXME: fails -
		/*
		 failed - Expected to retrieve found(feed: [EssentialDev_FeedProject.LocalFeedImage(id: 7BBF2042-2CB5-4A70-9499-80A140ACA56A, description: Optional(""), location: nil, url: http://any-url.com), EssentialDev_FeedProject.LocalFeedImage(id: 46485063-6E1D-4894-A52D-0FC7BED78781, description: Optional(""), location: nil, url: http://any-url.com)], timestamp: 2024-03-23 19:33:26 +0000), got empty instead
		 */
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}

	func test_retrieve_deliversFailureOnRetrievalError() {
		/*
		 FIXME: fails -
		 Expected to retrieve failure(Error Domain=any error Code=0 "(null)"), got empty instead
		 */
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		do {
			try? "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		}

		expect(sut, toRetrieve: .failure(anyNSError()))
	}
	
	func test_retrieve_hasNoSideEffectsOnFailure() {
		// FIXME: fails -
		/*
		 Expected to retrieve failure(Error Domain=any error Code=0 "(null)"), got empty instead
		 */
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		do {
			try? "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
		}

		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}
	
	// MARK: Insert
	func test_insert_deliversNoErrorOnEmptyCache() {
		/*
		 FIXME: fails -
		 "Error Domain=NSCocoaErrorDomain Code=4 "The file “CodableFeedStoreTests.store” doesn’t exist." UserInfo={NSFilePath=/Users/tpoland/Library/Developer/XCTestDevices/35A4D970-AAEA-44D7-8E22-D6D1A322880A/data/Containers/Data/Application/7F7BA41A-E4F4-480F-AE7C-C959E0BE21DA/Library/Caches/CodableFeedStoreTests.store, NSUnderlyingError=0x600000d34180 {Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}}" - Expected to insert cache successfully
		 */
		let sut = makeSUT()

		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

		XCTAssertNil(insertionError, "Expected to insert cache successfully")
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

		XCTAssertNil(insertionError, "Expected to override cache successfully")
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}

	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		let insertionError = insert((feed, timestamp), to: sut)

		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
	}

	func test_insert_hasNoSideEffectsOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .empty)
	}

	// MARK: Delete

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty)
	}

	// FIXME: when this test is uncommented, the `try!` in above tests crashes (cant find file/directory)
	func test_delete_deliversErrorOnDeletionError() {
		let noDeletePermissionURL = noDeletePermissionsURL()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
	}

	func test_delete_hasNoSideEffectsOnDeletionError() {
		let noDeletePermissionURL = noDeletePermissionsURL()
		let sut = makeSUT(storeURL: noDeletePermissionURL)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty)
	}


	// MARK: Side Effects
	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()
		var completedOperationsInOrder = [XCTestExpectation]()

		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}

		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}

		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}

		waitForExpectations(timeout: 5.0)

		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
	}
	
	// - MARK: Helpers
	
	private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}
	
	@discardableResult
	private func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}
	
	private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")
		
		sut.retrieve { retrievedResult in
			switch (expectedResult, retrievedResult) {
			case (.empty, .empty),
				(.failure, .failure):
				break
				
			case let (.found(expected), .found(retrieved)):
				XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
				XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)

			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}
	
	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}
	
	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}
	
	private func testSpecificStoreURL() -> URL {
		return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
	}
	
	private func cachesDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

	private func noDeletePermissionsURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
	}

}
