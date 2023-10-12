//
//  RemoteFeedLoaderTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/10/23.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        // this logic moved out of RemoteFeedLoader and into HTTPClient
        requestedURL = url
    }
    
}

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // ways of doing DI
        // 1. method injection, like:
        //      sut.load(client: client)
        // 2. constructor/init injection, like:
        //      RemoteFeedLoader(client: client)
        // 3. property injection
        //      let client = HTTPClient()
        //      client.requestedURL = URL(string: "https://an-example-url.com")
        
        // but there's also a concrete way (probably not recommended for most scenarios:
//         let client = HTTPClient. // 🤢 - Why would this need to be a singleton? I could (should) have more than one HTTP Client
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
