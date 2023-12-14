//
//  FeedItemsMapper.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

internal final class FeedItemMapper {
	
	internal static func map(_ data: Data,
							 from response: HTTPURLResponse
	) throws -> [RemoteFeedItem] {
		guard response.statusCode == HTTPCode.statusOK,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return root.items
	}
	
	private struct HTTPCode {
		static var statusOK: Int = 200
	}
	
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}
}
