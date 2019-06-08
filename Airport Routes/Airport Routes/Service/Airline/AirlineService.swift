enum AirlineServiceError: Error {
    case couldNotParseCSV
}
protocol AirlineServiceProtocol {
    typealias Handler = (Result<Airlines, AirlineServiceError>) -> Void
    func getAirlines(completion: Handler)
}
class AirlineService: AirlineServiceProtocol {
    private let endpoint = "airlines"
    let csvReader: CSVReaderProtocol
    
    init(csvReader: CSVReaderProtocol) {
        self.csvReader = csvReader
    }
    
    func getAirlines(completion: Handler) {
        guard let parsedCSV = csvReader.parseCSV(filename: endpoint) else {
            completion(.failure(.couldNotParseCSV))
            return
        }
        let airlines = parsedCSV.compactMap{ row in
            return Airline(name: row[0], code2Digit: row[1], code3Digit: row[2], country: row[3])
        }
        completion(.success(Airlines(airlines: airlines)))
    }
}
