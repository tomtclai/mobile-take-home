struct Routes {
    let byOrigin: [String: Set<Route>]
    let byDestination: [String: Set<Route>]
    
    init(routes: [Route]) {
        var originDict = [String: Set<Route>]()
        var destDict = [String: Set<Route>]()
        
        func groupByOrigin(route: Route) {
            createSetIfNeeded(airportCode: route.origin, map: &originDict)
            originDict[route.origin]?.insert(route)
        }
        
        func groupByDestination(route: Route) {
            createSetIfNeeded(airportCode: route.destination, map: &destDict)
            destDict[route.destination]?.insert(route)
        }
        
        func createSetIfNeeded(airportCode: String, map: inout [String: Set<Route>]) {
            if map[airportCode] == nil {
                map[airportCode] = Set<Route>()
            }
        }
        
        for route in routes {
            groupByOrigin(route: route)
            groupByDestination(route: route)
        }
        
        byOrigin = originDict
        byDestination = destDict
    }

}
