//
//  URLSessionHTTPClientTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/21/23.
//

import XCTest

class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession) {
		self.session = session
	}
	
	func get(from url: URL) {
		session.dataTask(with: url) { _, _, _ in
			
		}
		
	}
}

final class URLSessionHTTPClientTests: XCTestCase {

	func test_getFromURL_createDataTaskWithURL() {
		let url = URL(string: "http://any-url")!
		let session = URLSessionSpy()
		let sut = URLSessionHTTPClient(session: session)
		sut.get(from: url)
		
		XCTAssertEqual(session.receivedURLs, [url])
	}
	
	// MARK: - TEST HELPERS
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		
		private static let config = URLSessionConfiguration.default
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			
			return FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTask {}

}

