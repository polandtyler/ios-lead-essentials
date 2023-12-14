//
//  URLSessionHTTPClientTests.swift
//  EssentialDev_FeedProjectTests
//
//  Created by Poland, Tyler on 10/21/23.
//

import XCTest
import EssentialDev_FeedProject

final class URLSessionHTTPClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		URLProtocolStub.startInterceptingRequests()
	}
	
	override func tearDown() {
		URLProtocolStub.stopInterceptingRequests()
		super.tearDown()
	}

	func test_getFromURL_performsGETRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "Wait for request")
		
		exp.expectedFulfillmentCount = 2
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}

		makeSUT().get(from: url) { _ in
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}
	
	func test_getFromURL_failsOnAllNilValues() {
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
	}
	
	func test_getFromUrl_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpUrlResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpUrlResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpUrlResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: anyNSError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpUrlResponse(), error: nil))
	}
	
	func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
		let data = anyData()
		let response = anyHttpUrlResponse()
		let receivedValues = resultValuesFor(data: data, response: response, error: nil)
		
		XCTAssertEqual(receivedValues?.data, data)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	func test_getFromURL_succeedsWithEmptyDataOnHttpUrlResponseWithNilData() {
		let response = anyHttpUrlResponse()
		let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
		
		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data, emptyData)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	// MARK: - TEST HELPERS
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let sut = URLSessionHTTPClient(session: URLSession.shared)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func anyData() -> Data {
		return Data("any data".utf8)
	}
	
	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private func nonHttpUrlResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
	private func anyHttpUrlResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func resultErrorFor(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		file: StaticString = #file,
		line: UInt = #line
	) -> Error? {
		let result = resultFor(data: data, response: response, error: error, file: file, line: line)
		
		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Expected failure with error, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultValuesFor(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		file: StaticString = #file,
		line: UInt = #line
	) -> (data: Data, response: HTTPURLResponse)? {
		let result = resultFor(data: data, response: response, error: error)
		
		switch result {
		case let .success(data, response):
			return (data, response)
		default:
			XCTFail("Expected success, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultFor(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		file: StaticString = #file,
		line: UInt = #line
	) -> HTTPClientResult {
		
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSUT(file: file, line: line)
		let expectation = expectation(description: "Wait for completion")
		
		var receivedResult: HTTPClientResult!
		sut.get(from: anyURL()) { result in
			switch result {
			case let .failure(error):
				receivedResult = .failure(error)
			case let .success(data, response):
				receivedResult = .success(data, response)
			}
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: 1.0)
		
		return receivedResult
		
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://a-url.com")!
	}
	
	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		
		private static var requestObserver: ((URLRequest) -> Void)?
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?, response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}
		
		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)
			requestObserver = nil
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			
			if let error = URLProtocolStub.stub?.error {
				print("### Pre-Error: \(error)")
				client?.urlProtocol(self, didFailWithError: error)
				print("### Post-Error: \(error)")
			}
			
			client?.urlProtocolDidFinishLoading(self)
		}
		
		override func stopLoading() {}
	}
	
}

