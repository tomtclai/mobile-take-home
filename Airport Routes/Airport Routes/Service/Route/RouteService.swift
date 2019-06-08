enum RouteServiceError: Error {
    case couldNotParseCSV
}
protocol RouteServiceProtocol {
    typealias Handler = (Result<Routes, RouteServiceError>) -> Void
    func getRoutes(completion: Handler)
}
class RouteService: RouteServiceProtocol {
    private let endpoint = "routes"
    let csvReader: CSVReaderProtocol
    
    init(csvReader: CSVReaderProtocol) {
        self.csvReader = csvReader
    }
    
    func getRoutes(completion: Handler) {
        guard let parsedCSV = csvReader.parseCSV(filename: endpoint) else {
            completion(.failure(.couldNotParseCSV))
            return
        }
        let routes = parsedCSV.compactMap{ row in
            return Route(airlineID: row[0], origin: row[1], destination: row[2])
        }
        completion(.success(Routes(routes: routes)))
    }
}
