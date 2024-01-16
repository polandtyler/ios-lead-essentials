//
//  FeedStore.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 12/12/23.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}

public enum RetrieveCachedFeedResult {
	case empty
	case found(feed: [LocalFeedImage], timestamp: Date)
	case failure(Error)
}

/*
 - Retrieve
	✅ Empty cache returns empty
	✅ empty cache twice returns empty (no side effects)
	✅ non-empty cache returns data
	✅ Non-empty cache twice returns the same data (no side-effects)
	✅ Error (if applicable - ex: invalid data)
	✅ Error twice returns same error
 - Insert
	✅ To empty cache
	- To non-empty cache overrides previous data with new data
	- Error (if applicable - ex: no write permission, out of space, etc)
 - Delete
	- Empty cache does nothing (cache stays empty and does not fail)
	- Non-empty cache leaves cache empty
	- Error (if applicable - ex: no delete permissions)
 - Side effects must run serially to avoid race conditions
 */

