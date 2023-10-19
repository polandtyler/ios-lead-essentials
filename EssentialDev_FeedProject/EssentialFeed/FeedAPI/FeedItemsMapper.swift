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
	) -> RemoteFeedLoader.Result {
		guard response.statusCode == HTTPCode.statusOK,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feed)
	}
	
	private struct HTTPCode {
		static var statusOK: Int = 200
	}
	
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedItem] {
			return items.map { $0.item }
		}
	}
	
	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL
		
		var item: FeedItem {
			return FeedItem(id: id, description: description, location: location, imageURL: image)
		}
		
	}
}
