//
//  RemoteFeedLoaderTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/10/23.
//

import XCTest

class HTTPClient {
//    static let shared = HTTPClient()
//
//    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoader {
    func load() {}
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
    }

}
