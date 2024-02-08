//
//  RemoteFeedItem.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 12/14/23.
//

import Foundation

 struct RemoteFeedItem: Decodable {
	 let id: UUID
	 let description: String?
	 let location: String?
	 let url: URL
}
