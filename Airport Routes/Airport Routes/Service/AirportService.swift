import Foundation
enum AirportServiceError: Error {
    case couldNotParseCSV
}
protocol AirportServiceProtocol {
    typealias Handler = (Result<Airports, AirportServiceError>) -> Void
    func getAirports(completion: Handler)
}
class AirportService: AirportServiceProtocol {
    private let endpoint = "airports"
    let csvReader: CSVReaderProtocol
    
    init(csvReader: CSVReaderProtocol) {
        self.csvReader = csvReader
    }
    
    func getAirports(completion: Handler) {
        guard let parsedCSV = csvReader.parseCSV(filename: endpoint) else {
            completion(.failure(.couldNotParseCSV))
            return
        }
        let airports = parsedCSV.compactMap{ row in
            return Airport(name: row[0], city: row[1], country: row[2], iata3: row[3], latitude: row[4], longitude: row[5])
        }
        completion(.success(Airports(airports: airports)))
    }
}
