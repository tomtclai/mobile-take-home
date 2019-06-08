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
    func shortestPathBetween(originCode: String, destinationCode destCode: String, completion: Handler)
}
class RouteManager: RouteManagerProtocol {
    let routes: Routes
    let airports: Airports
    
    init(routes: Routes, airports: Airports) {
        self.routes = routes
        self.airports = airports
    }
    
    class DikstraColumn {
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
    
    func shortestPathBetween(originCode: String, destinationCode destCode: String, completion: Handler){
        guard let origin = airports.byAirportCode[originCode] else { completion(.failure(.noSuchAirport(originCode)))
            return
        }
        guard let destination = airports.byAirportCode[destCode] else { completion(.failure(.noSuchAirport(destCode)))
            return
        }
        let dikstraTable: [String: DikstraColumn] = airports.allAirports.reduce([String: DikstraColumn]()) { dict, airport in
            var dictionary = dict
            dictionary[airport.iata3] = DikstraColumn(vertex: airport)
            return dictionary
        }
        
        var airportToVisit = [origin.iata3]
        while !airportToVisit.isEmpty {
            let source = airportToVisit.removeFirst()
            guard nil != dikstraTable[source] else {
                completion(.failure(.unwrappingError))
                return
            }
            dikstraTable[source]!.distance = 0
            
            guard let reachableFromThisAirport = routes.byOrigin[source] else {
                print("Nothing is reachable from this airport")
                break
            }
            
            let destinations = reachableFromThisAirport.map{$0.destination}
            
            airportToVisit.append(contentsOf: destinations)
            
            for route in reachableFromThisAirport {
                guard let dikstraDest = dikstraTable[route.destination],
                    let dikstraSource = dikstraTable[route.origin] else {
                        completion(.failure(.dataSourceError))
                        return
                }
                if dikstraDest.distance > dikstraSource.distance + 1 {
                    dikstraTable[route.destination]!.distance = dikstraSource.distance + 1
                    dikstraTable[route.destination]!.path = route
                }
            }
        }
        
        var currIndex = destination.iata3
        var entireRoute = [Route]()
        while let path = dikstraTable[currIndex]?.path {
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
