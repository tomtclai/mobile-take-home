//
//  CSVReaderTests.swift
//  Airport RoutesTests
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import XCTest
@testable import Airport_Routes

class CSVReaderTests: XCTestCase {

    let reader = CSVReader()

    func testReadingAirports() {
        let parsedCSV = reader.parseCSV(filename: "airports")
        XCTAssertNotNil(parsedCSV)
        XCTAssertEqual(parsedCSV?.first?.count, 6)
    }
    
    func testReadingRoutes() {
        let parsedCSV = reader.parseCSV(filename: "routes")
        XCTAssertNotNil(parsedCSV)
        XCTAssertEqual(parsedCSV?.first?.count, 3)
    }
}
