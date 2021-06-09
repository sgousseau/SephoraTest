//
//  SephoraTestTests.swift
//  SephoraTestTests
//
//  Created by Sébastien Gousseau on 08/06/2021.
//

import XCTest
@testable import SephoraTest

class SephoraTestTests: XCTestCase {

    func testSetGet() throws {
        let cache = CacheService.local
        let data = "Hello from tests".data(using: .utf8)
        let url = URL(string: "/tests")!
        let set_expect = XCTestExpectation()
        let get_expect = XCTestExpectation()

        cache.set(url, data) { success, error in
            if success {
                set_expect.fulfill()
            } else {
                set_expect.isInverted = true
                set_expect.fulfill()
            }

            cache.get(url) { data, error in
                if let data = data {
                    XCTAssert(String(data: data, encoding: .utf8) == "Hello from tests")
                    get_expect.fulfill()
                } else {
                    get_expect.isInverted = true
                    get_expect.fulfill()
                }
            }
        }
    }

}
