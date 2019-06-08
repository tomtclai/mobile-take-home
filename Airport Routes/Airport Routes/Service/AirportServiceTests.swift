//
//  AirportServiceTests.swift
//  Airport RoutesTests
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import XCTest
@testable import Airport_Routes

class AirportServiceTests: XCTestCase {
    var airportService: AirportService!
    override func setUp() {
        airportService = AirportService(csvReader: CSVReader())
    }

    func testGettingAirportShouldSucceed() {
        let expectation = XCTestExpectation(description: "airport service returns airports")
        var receivedAirports: Airports?
        airportService.getAirports { result in
            switch result {
            case .success(let airports):
                receivedAirports = airports
                expectation.fulfill()
            case .failure:
                XCTFail("This call should not fail in this test")
            }
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(receivedAirports)
    }
    
    func testGettingAirportShouldFail() {
        airportService = AirportService(csvReader: FakeCSVReader())
        let expectation = XCTestExpectation(description: "airport service returns airports")
        airportService.getAirports { result in
            switch result {
            case .success:
                XCTFail("This call should not succeed in this test")
            case .failure(let error):
                expectation.fulfill()
                XCTAssertEqual(error, .couldNotParseCSV)
            }
        }
        wait(for: [expectation], timeout: 0.5)
    }
}

private struct FakeCSVReader: CSVReaderProtocol {
    func parseCSV(filename: String) -> [[String]]? {
        return nil
    }
}
