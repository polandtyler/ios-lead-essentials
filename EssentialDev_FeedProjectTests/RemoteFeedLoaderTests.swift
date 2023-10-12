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
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
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
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
