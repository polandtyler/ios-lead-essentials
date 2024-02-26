//
//  HTTPCLient.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

// MARK: - Client

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible for dispatching to appropriate threads, if necessary.
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

protocol HTTPSessionTask {
	func resume()
}
