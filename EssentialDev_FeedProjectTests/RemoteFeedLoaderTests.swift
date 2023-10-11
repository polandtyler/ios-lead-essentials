//
//  RemoteFeedLoaderTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/10/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "ttps://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    

}
