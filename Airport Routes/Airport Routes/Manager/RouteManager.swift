//
//  Class to figure out shortest routes

import Foundation

class RouteManager {
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
    
    func shortestPathBetween(originCode: String, destinationCode destCode: String) -> [Route] {
        guard let origin = airports.byAirportCode[originCode],
            let destination = airports.byAirportCode[destCode] else { return [] }
        let dikstraTable: [String: DikstraColumn] = airports.allAirports.reduce([String: DikstraColumn]()) { dict, airport in
            var dictionary = dict
            dictionary[airport.iata3] = DikstraColumn(vertex: airport)
            return dictionary
        }
        
        var airportToVisit = [origin.iata3]
        while !airportToVisit.isEmpty {
            let source = airportToVisit.removeFirst()
            guard nil != dikstraTable[source] else { return [] }
            dikstraTable[source]!.distance = 0
            
            guard let reachableFromThisAirport = routes.byOrigin[source] else {
                print("Nothing is reachable from this airport")
                break
            }
            
            let destinations = reachableFromThisAirport.map{$0.destination}
            
            airportToVisit.append(contentsOf: destinations)
            
            for route in reachableFromThisAirport {
                if dikstraTable[route.destination]!.distance > dikstraTable[source]!.distance + 1 {
                    dikstraTable[route.destination]!.distance = dikstraTable[source]!.distance + 1
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
        
        return entireRoute
    }
}
