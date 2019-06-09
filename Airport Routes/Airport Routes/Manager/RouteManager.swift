//
//  Class to figure out shortest routes

import Foundation
enum RouteManagerError: Error, Equatable {
    case noRoutes
    case noSuchAirport(String)
    case unwrappingError
    case dataSourceError
}

// Normally sourcery is used for this, except for this project we are not using third party library.
func ==(lhs: RouteManagerError, rhs: RouteManagerError) -> Bool {
    switch (lhs, rhs) {
    case (.noRoutes, .noRoutes),
         (.unwrappingError, .unwrappingError),
         (.dataSourceError, .dataSourceError):
        return true
    case let (.noSuchAirport(a), .noSuchAirport(b)):
        return a == b
    default:
        return false
    }
}

protocol RouteManagerProtocol {
    typealias Handler = (Result<[Route], RouteManagerError>) -> Void
    func shortestPathBetween(originCode: String, destinationCode destCode: String, completion: @escaping Handler)
}
class RouteManager: RouteManagerProtocol {
    let routes: Routes
    let airports: Airports
    
    init(routes: Routes, airports: Airports) {
        self.routes = routes
        self.airports = airports
    }
    
    class DijkstraColumn {
        var vertex: Airport
        var visited: Bool
        var path: Route?
        var distance: Int
        init (vertex: Airport) {
            self.vertex = vertex
            visited = false
            path = nil
            distance = Int.max
        }
    }
    func shortestPathBetween(originCode: String, destinationCode destCode: String, completion: @escaping Handler){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.shortestPathBetweenHelper(originCode: originCode, destinationCode: destCode, completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            })
        }
    }
    func shortestPathBetweenHelper(originCode: String, destinationCode destCode: String, completion: Handler){
        
        guard let origin = airports.byAirportCode[originCode] else { completion(.failure(.noSuchAirport(originCode)))
            return
        }
        guard let destination = airports.byAirportCode[destCode] else { completion(.failure(.noSuchAirport(destCode)))
            return
        }
        let dijkstraTable: [String: DijkstraColumn] = airports.allAirports.reduce([String: DijkstraColumn]()) { dict, airport in
            var dictionary = dict
            dictionary[airport.iata3] = DijkstraColumn(vertex: airport)
            return dictionary
        }
        
        var airportToVisit = [origin.iata3]
        dijkstraTable[originCode]!.distance = 0
        while !airportToVisit.isEmpty {
            
            let source = airportToVisit.removeFirst()
            
            guard let dijkstraSource = dijkstraTable[source], !dijkstraSource.visited else {
                continue
            }
            dijkstraTable[source]!.visited = true
            
            guard let routesFromVertex = routes.byOrigin[source] else {
                continue
            }
            
            let routesWithRealAirportsFromVertex = routesFromVertex.filter({ route in
                return airports.byAirportCode[route.destination] != nil && airports.byAirportCode[route.origin] != nil
            })
            
            let destinations = routesWithRealAirportsFromVertex.map{$0.destination}
            
            airportToVisit.append(contentsOf: destinations)
            
            for route in routesWithRealAirportsFromVertex {
                guard let dijkstraSource = dijkstraTable[route.origin] else {
                    print("FIXME: Route dataset contains airport code \(route.origin) but it is not in the airport dataset")
                        continue
                }
                guard let dijkstraDest = dijkstraTable[route.destination] else {
                    print("FIXME: Route dataset contains airport code \(route.destination) but it is not in the airport dataset")
                        continue
                }
                if dijkstraDest.distance > dijkstraSource.distance + 1 {
                    dijkstraTable[route.destination]!.distance = dijkstraSource.distance + 1
                    dijkstraTable[route.destination]!.path = route
                }
            }
        }
        
        var currIndex = destination.iata3
        var entireRoute = [Route]()
        while let path = dijkstraTable[currIndex]?.path {
            entireRoute.insert(path, at: 0)
            currIndex = path.origin
        }
        
        guard !entireRoute.isEmpty else {
            completion(.failure(.noRoutes))
            return
        }
        completion(.success(entireRoute))
    }
}
