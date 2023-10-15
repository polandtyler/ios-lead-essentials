//
//  RemoteFeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/12/23.
//

import Foundation

// MARK: - Client
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

// MARK: - Loader
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let response):
				completion(.failure(.invalidData))
            case .failure(let error):
				completion(.failure(.connectivity))
            }
        }
    }
}
