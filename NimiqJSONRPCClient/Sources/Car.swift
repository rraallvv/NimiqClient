//
//  Car.swift
//  NimiqJSONRPCClient
//
//  Created by Rhody Lugo on 7/12/20.
//  Copyright © 2020 Rhody Lugo. All rights reserved.
//

import Foundation

public class Car: CustomStringConvertible {

    var name: String
    var miles: Int

    public init(name: String, miles: Int) {
        self.name = name
        self.miles = miles
    }

    public func addMiles(miles: Int) {
        self.miles += miles
    }

    public var description: String {
        return "Car '\(name)' has \(miles) miles."
    }
    
}
