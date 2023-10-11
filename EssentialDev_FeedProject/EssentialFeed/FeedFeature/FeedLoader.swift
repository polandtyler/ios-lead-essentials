//
//  FeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/10/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

class RemoteFeedLoader: FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        return
    }
    
    
}

class LocalFeedLoader: FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        return
    }
    
    
}
