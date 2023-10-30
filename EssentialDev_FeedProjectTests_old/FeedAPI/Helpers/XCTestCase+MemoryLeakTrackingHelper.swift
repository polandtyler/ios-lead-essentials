//
//  XCTestCase+MemoryLeakTrackingHelper.swift
//  EssentialDev_FeedProject
//
//  Created by Poland, Tyler on 10/29/23.
//

import XCTest

extension XCTestCase {
	public func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been dealloc'ed. Potential memory leak.",
						 file: file,
						 line: line)
		}
	}
}
