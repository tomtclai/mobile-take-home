//
//  RouteManagerTests.swift
//  Airport RoutesTests
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import XCTest
@testable import Airport_Routes
class RouteManagerTests: XCTestCase {
    var routeManager: RouteManager!
    override func setUp() {
        routeManager = RouteManager(routes: Routes(routes: [Route(origin: "SEA", destination: "VVX"),
                                                            Route(origin: "VVX", destination: "COT"),
                                                            Route(origin: "VVX", destination: "SVG"),
                                                            Route(origin: "SVG", destination: "COT"),
                                                            Route(origin: "COT", destination: "PDX")]),
                                    airports: Airports(airports: ["SEA", "VVX", "COT", "PDX", "SVG"].map(Airport.init)))
    }
    
    func testShortestPathWith3Legs() {
        let expectation = XCTestExpectation(description: "route manager returns routes")
        routeManager.shortestPathBetween(originCode: "SEA", destinationCode: "PDX", completion: { result in
            switch result {
            case .success(let paths):
                XCTAssertEqual(paths, [Route(origin: "SEA", destination: "VVX"),
                                       Route(origin: "VVX", destination: "COT"),
                                       Route(origin: "COT", destination: "PDX")])
            case .failure:
                XCTFail("testShortestPathWith3Legs should not fail")
            }
            expectation.fulfill()
        })
        
    }
    
    func testShortestPathWith1Leg() {
        routeManager.shortestPathBetween(originCode: "COT", destinationCode: "PDX", completion: { result in
            switch result {
                case .success(let paths):
                XCTAssertEqual(paths, [Route(origin: "COT", destination: "PDX")])
            case .failure:
                XCTFail("testShortestPathWith1Leg should not fail")
            }
        })
    }
    
    func testShortestPathWithSameAirport() {
        routeManager.shortestPathBetween(originCode: "PDX", destinationCode: "PDX", completion: { result in
            switch result {
            case .success:
                XCTFail("testShortestPathWithSameAirport should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .noRoutes)
            }
        })
    }
    
    func testShortestPathWithNoLegs() {
        routeManager.shortestPathBetween(originCode: "PDX", destinationCode: "SVG", completion: { result in
            switch result {
            case .success:
                XCTFail("testShortestPathWithNoLegs should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .noRoutes)
            }
        })
    }
}

extension Airport {
    init(iata3: String) {
        self.init(name: "", city: "", country: "", iata3: iata3, latitude: "0.0", longitude: "0.0")!
    }
}

extension Route {
    init(origin: String, destination: String) {
        self.init(airlineID: "", origin: origin, destination: destination)
    }
}
