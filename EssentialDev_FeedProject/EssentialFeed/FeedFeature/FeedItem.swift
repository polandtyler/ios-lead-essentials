//
//  FeedItem.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/10/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
