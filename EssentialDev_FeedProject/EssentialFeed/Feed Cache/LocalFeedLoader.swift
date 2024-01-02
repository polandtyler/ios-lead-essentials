//
//  LocalFeedLoader.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 12/12/23.
//

import Foundation

public final class LocalFeedLoader {
	
	public typealias SaveResult = Error?
	public typealias LoadResult = LoadFeedResult
	
	private let store: FeedStore
	private let currentDate: () -> Date
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	private var maxCacheAgeInDays: Int {
		return 7
	}
	
	private func validate(_ timestamp: Date) -> Bool {
		let calendar = Calendar(identifier: .gregorian)
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
		return currentDate() < maxCacheAge
	}
}

extension LocalFeedLoader {
	
	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [unowned self] result in
			switch result {
			case let .failure(error):
				completion(.failure(error))
				
			case let .found(feed, timestamp) where self.validate(timestamp):
				completion(.success(feed.toModels()))
				
			case .empty, .found:
				completion(.success([]))
			}
		}
	}
}

extension LocalFeedLoader {
	public func validateCache() {
		store.retrieve { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .failure(_):
				self.store.deleteCachedFeed { _ in }
				
			case let .found(_, timestamp) where !self.validate(timestamp):
				self.store.deleteCachedFeed { _ in }
				
			case .empty, .found: break
			}
		}
	}
}

extension LocalFeedLoader {
	
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

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
