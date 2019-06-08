
import XCTest
@testable import Airport_Routes

class AirlineServiceTests: XCTestCase {
    private var fakeCSVReader: FakeCSVReader!
    var airlineService: AirlineService!
    override func setUp() {
        fakeCSVReader = FakeCSVReader()
        airlineService = AirlineService(csvReader: fakeCSVReader)
    }
    
    func testGettingAirlineShouldSucceed() {
        fakeCSVReader.readerResponse = [["Turkish Airlines","TK","THY","Turkey"],["United Airlines","UA","UAL","United States"]]
        let expectation = XCTestExpectation(description: "airline service returns airlines")
        var receivedAirlines: Airlines?
        airlineService.getAirlines { result in
            switch result {
            case .success(let airlines):
                receivedAirlines = airlines
                expectation.fulfill()
            case .failure:
                XCTFail("This call should not fail in this test")
            }
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(receivedAirlines)
        XCTAssertEqual(receivedAirlines?.by2DigitCode["TK"], Airline(name: "Turkish Airlines", code2Digit: "TK", code3Digit: "THY", country: "Turkey") )
    }
    
    func testGettingAirlineShouldFail() {
        fakeCSVReader.readerResponse = nil
        airlineService = AirlineService(csvReader: FakeCSVReader())
        let expectation = XCTestExpectation(description: "airline service returns airlines")
        airlineService.getAirlines { result in
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
