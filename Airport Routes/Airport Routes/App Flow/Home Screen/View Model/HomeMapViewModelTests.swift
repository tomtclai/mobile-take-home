//
//  HomeMapViewModelTests.swift
//  Airport RoutesTests
//
//  Created by Tom Lai on 6/9/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import XCTest
import MapKit
@testable import Airport_Routes

class HomeMapViewModelTests: XCTestCase {
    var homeMapViewModel: HomeMapViewModel!
    var fakeAirportService = FakeAirportService()
    var fakeRouteService = FakeRouteService()
    var fakeAirlineService = FakeAirlineService()
    var fakeRouteManagerFactory = FakeRouteManagerFactory()
    override func setUp() {
        homeMapViewModel = HomeMapViewModel(airportService: fakeAirportService, routeService: fakeRouteService, airlineService: fakeAirlineService, routeManagerFactory: fakeRouteManagerFactory)
        homeMapViewModel.viewDidLoad()
    }

    func testSearchRoutes() {
        let expectation = XCTestExpectation(description: "SearchingForRoutes should return 5 lines beteen 6 points")
        homeMapViewModel.searchForRoutes(origin: "SEA", destination: "COT") { (overlay, annotations, strings) in
            XCTAssertNotNil(overlay)
            XCTAssertEqual(annotations.count, 6)
            XCTAssertEqual(annotations[0].title, "1.  (SEA)")
            XCTAssertEqual(annotations[1].title, "2.  (VVX)")
            XCTAssertEqual(annotations[2].title, "3.  (COT)")
            XCTAssertEqual(annotations[3].title, "4.  (SVG)")
            XCTAssertEqual(annotations[4].title, "5.  (COT)")
            XCTAssertEqual(annotations[5].title, "6.  (PDX)")
            XCTAssertEqual(strings, ["SEA", "VVX", "COT", "SVG", "COT", "PDX"])
            expectation.fulfill()
        }
    }
}

// Move in to own file if there are more tests that use it
class FakeAirportService: AirportServiceProtocol {
    func getAirports(completion: (Result<Airports, AirportServiceError>) -> Void) {
        completion(.success(Airports(airports: ["SEA", "VVX", "COT", "PDX", "SVG"].map(Airport.init))))
    }
}

class FakeRouteService: RouteServiceProtocol {
    func getRoutes(completion: (Result<Routes, RouteServiceError>) -> Void) {
        completion(.success(Routes(routes: [Route(origin: "SEA", destination: "VVX"),
                                            Route(origin: "VVX", destination: "COT"),
                                            Route(origin: "VVX", destination: "SVG"),
                                            Route(origin: "SVG", destination: "COT"),
                                            Route(origin: "COT", destination: "PDX")])))
    }
}

class FakeAirlineService: AirlineServiceProtocol {
    func getAirlines(completion: (Result<Airlines, AirlineServiceError>) -> Void) {
        completion(.success(Airlines(airlines: ["WS", "CZ", "WN", "CA", "UA"].map(Airline.init))))
    }
}

class FakeRouteManagerFactory: RouteManagerFactoryProtocol {
    
    class FakeRouteManager: RouteManagerProtocol {
        func shortestPathBetween(originCode: String, destinationCode destCode: String, completion: @escaping Handler) {
            completion(.success([Route(origin: "SEA", destination: "VVX"),
                                 Route(origin: "VVX", destination: "COT"),
                                 Route(origin: "VVX", destination: "SVG"),
                                 Route(origin: "SVG", destination: "COT"),
                                 Route(origin: "COT", destination: "PDX")]))
        }
    }
    
    func makeRouteManager(routes: Routes, airports: Airports) -> RouteManagerProtocol {
        return FakeRouteManager()
    }
}

extension Airline {
    init(_ code2Digit: String) {
        self.init(name: "", code2Digit: code2Digit, code3Digit: "", country: "")
    }
}

