//
//  RemoteFeedLoaderTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/10/23.
//

import XCTest

class HTTPClient {
    static var shared = HTTPClient() //  could make this a var in order to mock, but then we would be dealing with a shared global state... and aint nobody got time for that
    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    override func get(from url: URL) {
        // this logic moved out of RemoteFeedLoader and into HTTPClient
        requestedURL = url
    }
    
}

class RemoteFeedLoader {
    func load() {}
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
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
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
