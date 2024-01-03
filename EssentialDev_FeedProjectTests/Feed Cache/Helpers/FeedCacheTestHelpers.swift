//
//  FeedCacheTestHelpers.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 1/2/24.
//

import Foundation
import EssentialDev_FeedProject

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let local = models.map(localFeedItem(from:))
	return (models, local)
}

func uniqueImage() -> FeedImage {
	return FeedImage(id: UUID(),
					 description: "",
					 location: nil,
					 url: anyURL())
}

func localFeedItem(from item: FeedImage) -> LocalFeedImage {
	LocalFeedImage(id: item.id, description: item.description, location: item.location, url: item.url)
}

extension Date {
	private func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: Date())!
	}
	
	private var feedCacheMaxAgeInDays: Int {
		return 7
	}
	
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
