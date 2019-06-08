
import XCTest
@testable import Airport_Routes

class RouteServiceTests: XCTestCase {
    private var fakeCSVReader: FakeCSVReader!
    var routeService: RouteService!
    override func setUp() {
        fakeCSVReader = FakeCSVReader()
        routeService = RouteService(csvReader: fakeCSVReader)
    }
    
    func testGettingRouteShouldSucceed() {
        fakeCSVReader.readerResponse = [["AC","CMH","YYZ"], ["AC","YHZ","YYZ"],["AC","COO","ABJ"],["AC","COO","SEA"]]
        let expectation = XCTestExpectation(description: "route service returns routes")
        var receivedRoutes: Routes?
        routeService.getRoutes { result in
            switch result {
            case .success(let routes):
                receivedRoutes = routes
                expectation.fulfill()
            case .failure:
                XCTFail("This call should not fail in this test")
            }
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(receivedRoutes)
        XCTAssertEqual(receivedRoutes?.byDestination["YYZ"], Set(arrayLiteral: Route(airlineID: "AC", origin: "CMH", destination: "YYZ"),
                                                                 Route(airlineID: "AC", origin: "YHZ", destination: "YYZ")))
        XCTAssertEqual(receivedRoutes?.byOrigin["COO"], Set(arrayLiteral: Route(airlineID: "AC", origin: "COO", destination: "ABJ"),
                                                                 Route(airlineID: "AC", origin: "COO", destination: "SEA")))
    }
    
    func testGettingRouteShouldFail() {
        fakeCSVReader.readerResponse = nil
        routeService = RouteService(csvReader: FakeCSVReader())
        let expectation = XCTestExpectation(description: "route service returns routes")
        routeService.getRoutes { result in
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
