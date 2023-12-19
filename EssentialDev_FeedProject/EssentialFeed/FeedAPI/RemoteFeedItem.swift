//
//  RemoteFeedItem.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 12/14/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let url: URL
}
