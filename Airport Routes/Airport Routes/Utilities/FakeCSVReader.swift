import XCTest
@testable import Airport_Routes

class FakeCSVReader: CSVReaderProtocol {
    public var readerResponse: [[String]]?
    func parseCSV(filename: String) -> [[String]]? {
        return readerResponse
    }
}
