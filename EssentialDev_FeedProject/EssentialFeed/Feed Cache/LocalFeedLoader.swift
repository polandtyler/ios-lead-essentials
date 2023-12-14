//
//  LocalFeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 12/12/23.
//

import Foundation

public final class LocalFeedLoader {
	
	public typealias SaveResult = Error?
	
	private let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func load() {
		store.retrieve()
	}
	
	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] error in
			guard let self else { return }
			
			if error == nil {
				self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
					guard self != nil else { return }
					completion(error)
				}
			} else {
				completion(error)
			}
		}
	}
	
	private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: self.currentDate(), completion: { [weak self] error in
			guard self != nil else { return }
			completion(error)
		})
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map {
			LocalFeedImage(id: $0.id,
						  description: $0.description,
						  location: $0.location,
						   url: $0.url)
		}
	}
}
