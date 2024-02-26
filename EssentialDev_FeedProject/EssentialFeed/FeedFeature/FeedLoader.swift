//
//  FeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], Error>
	func load(completion: @escaping (Result) -> Void)
}
