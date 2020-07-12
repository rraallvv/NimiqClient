//
//  NimiqJSONRPCClientTests.swift
//  NimiqJSONRPCClient
//
//  Created by Rhody Lugo on 7/12/20.
//  Copyright © 2020 Rhody Lugo. All rights reserved.
//

import XCTest

class NimiqJSONRPCClientTests: XCTestCase {
    
    func testCarDescription() {
        let client = NimiqJSONRPCClient(name: "Test", miles: 0)
        XCTAssertEqual(client.description, "NimiqJSONRPCClient 'Test' has 0 miles.")
    }

    func testCarDescriptionAfterAddingMiles() {
        let client = NimiqJSONRPCClient(name: "Test", miles: 0)
        client.addMiles(miles: 125)
        XCTAssertEqual(client.description, "NimiqJSONRPCClient 'Test' has 125 miles.")
    }

}
