//
//  String+CSVQuotesTests.swift
//  Airport RoutesTests
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import XCTest
@testable import Airport_Routes
class String_CSVQuotesTests: XCTestCase {

    func testStringsWithQuotes() {
        let result = "\"Magdeburg \\City\"\" Airport\"\"\",Magdeburg,Germany,\\N,52.073612,11.626389".components(separatedBy: ",", escapingQuotes: "\"")
        XCTAssertEqual(result, ["Magdeburg \\City Airport", "Magdeburg", "Germany", "\\N", "52.073612", "11.626389"])
    }
    
    func testStringsWithoutQuotes() {
        let result = "Fort Dodge Regional Airport,Fort Dodge,United States,FOD,42.55149841,-94.19259644".components(separatedBy: ",", escapingQuotes: "\"")
        XCTAssertEqual(result, ["Fort Dodge Regional Airport", "Fort Dodge", "United States", "FOD", "42.55149841", "-94.19259644"])
    }

}
