//
//  FeedItemsMapper.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

internal final class FeedItemMapper {
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
		guard response.statusCode == HTTPCode.statusOK else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
	}
	
	private struct HTTPCode {
		static var statusOK: Int = 200
	}
	
	private struct Root: Decodable {
		let items: [Item]
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
