//
//  FeedStoreSpy.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 12/14/23.
//

import Foundation
import EssentialDev_FeedProject

class FeedStoreSpy: FeedStore {
	enum ReceivedMessage: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
	}
	
	private(set) var receivedMessages = [ReceivedMessage]()
	
	private var deletionCompletions = [DeletionCompletion]()
	private var insertionCompletions = [InsertionCompletion]()
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCachedFeed)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
	
	func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessages.append(.insert(items, timestamp))
	}
	
	func completeInsertion(with error: Error, at index: Int = 0) {
		insertionCompletions[index](error)
	}
	
	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletions[index](nil)
	}
	}
