//
//  RemoteFeedLoaderTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/10/23.
//

import XCTest

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://an-example-url.com")!
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let sut = RemoteFeedLoader()
        
        // ways of doing DI
        // 1. method injection, like:
        //      sut.load(client: client)
        // 2. constructor/init injection, like:
        //      RemoteFeedLoader(client: client)
        // 3. property injection
        //      let client = HTTPClient()
        //      client.requestedURL = URL(string: "https://an-example-url.com")
        
        // but there's also a concrete way (probably not recommended for most scenarios:
         let client = HTTPClient.shared // 🤢 - Why would this need to be a singleton? I could (should) have more than one HTTP Client
        
        
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
