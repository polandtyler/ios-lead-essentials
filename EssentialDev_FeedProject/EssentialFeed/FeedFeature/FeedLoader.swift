//
//  FeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
