//
//  CarTests.swift
//  NimiqJSONRPCClient
//
//  Created by Rhody Lugo on 7/12/20.
//  Copyright © 2020 Rhody Lugo. All rights reserved.
//

import XCTest

class CarTests: XCTestCase {
    
    func testCarDescription() {
        let car = Car(name: "Test", miles: 0)
        XCTAssertEqual(car.description, "Car 'Test' has 0 miles.")
    }

    func testCarDescriptionAfterAddingMiles() {
        let car = Car(name: "Test", miles: 0)
        car.addMiles(miles: 125)
        XCTAssertEqual(car.description, "Car 'Test' has 125 miles.")
    }

}
