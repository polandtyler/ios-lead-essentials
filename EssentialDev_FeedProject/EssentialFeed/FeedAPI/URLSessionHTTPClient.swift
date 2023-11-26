//
//  URLSessionHTTPClient.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/31/23.
//

import Foundation

enum HTTPClientError: Error {
	case callerReleasedUnexpectedly
}

public class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	private struct UnexpectedValuesRepresentationError: Error {}
	
	public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else {
				completion(.failure(HTTPClientError.callerReleasedUnexpectedly))
				return
			}
			if let error {
				completion(.failure(error))
			} else if let data = data, let response = response as? HTTPURLResponse {
				completion(.success(data, response))
			} else {
				completion(.failure(UnexpectedValuesRepresentationError()))
			}
		}.resume()
	}
}
