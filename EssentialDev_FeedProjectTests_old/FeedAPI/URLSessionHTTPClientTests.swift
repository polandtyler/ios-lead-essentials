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
		session.dataTask(with: url) { _, _, _ in }.resume()
	}
}

final class URLSessionHTTPClientTests: XCTestCase {
	
	func test_getFromURL_() {
		let url = URL(string: "http://any-url")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		let sut = URLSessionHTTPClient(session: session)
		session.stub(url: url, task: task)
		
		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	
	// MARK: - TEST HELPERS
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		private var stubs = [URL: URLSessionDataTask]()
		
		func stub(url: URL, task: URLSessionDataTask) {
			stubs[url] = task
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			
			return stubs[url] ?? FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTask {
		override func resume() {}
	}
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallCount: Int = 0
		
		override func resume() {
			resumeCallCount += 1
		}
	}

}

