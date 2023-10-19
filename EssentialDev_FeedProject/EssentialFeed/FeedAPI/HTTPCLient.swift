//
//  HTTPCLient.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/19/23.
//

import Foundation

// MARK: - Client
public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}
