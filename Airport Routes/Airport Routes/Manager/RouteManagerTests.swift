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
        let shortestPath = routeManager.shortestPathBetween(originCode: "SEA", destinationCode: "PDX")
        XCTAssertEqual(shortestPath, [Route(origin: "SEA", destination: "VVX"),
                                      Route(origin: "VVX", destination: "COT"),
                                      Route(origin: "COT", destination: "PDX")])
    }
    
    func testShortestPathWith1Leg() {
        let shortestPath = routeManager.shortestPathBetween(originCode: "COT", destinationCode: "PDX")
        XCTAssertEqual(shortestPath, [Route(origin: "COT", destination: "PDX")])
    }
    
    func testShortestPathWithNoLegs() {
        let shortestPath = routeManager.shortestPathBetween(originCode: "PDX", destinationCode: "SEA")
        XCTAssertEqual(shortestPath, [])
    }
}

private extension Airport {
    init(iata3: String) {
        self.init(name: "", city: "", country: "", iata3: iata3, latitude: "0.0", longitude: "0.0")!
    }
}

private extension Route {
    init(origin: String, destination: String) {
        self.init(airlineID: "", origin: origin, destination: destination)
    }
}
