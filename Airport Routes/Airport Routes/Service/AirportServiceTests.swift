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
    private var fakeCSVReader: FakeCSVReader!
    var airportService: AirportService!
    override func setUp() {
        fakeCSVReader = FakeCSVReader()
        airportService = AirportService(csvReader: fakeCSVReader)
    }

    func testGettingAirportShouldSucceed() {
        fakeCSVReader.readerResponse = [["Seattle Tacoma International Airport","Seattle","United States","SEA","47.44900131","-122.3089981"],["Shenyang Dongta Airport","Shenyang","China","\\N","41.78440094","123.4960022"]]
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
        XCTAssertEqual(receivedAirports?.byAirportCode["SEA"], Airport(name: "Seattle Tacoma International Airport", city: "Seattle", country: "United States", iata3: "SEA", latitude: "47.44900131", longitude: "-122.3089981"))
    }
    
    func testGettingAirportShouldFail() {
        fakeCSVReader.readerResponse = nil
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

private class FakeCSVReader: CSVReaderProtocol {
    public var readerResponse: [[String]]?
    func parseCSV(filename: String) -> [[String]]? {
        return readerResponse
    }
}
