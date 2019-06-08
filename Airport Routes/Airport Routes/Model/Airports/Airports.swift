struct Airports {
    let byAirportCode: [String: Airport]
    init(airports: [Airport]) {
        byAirportCode = airports.reduce([String: Airport]()) { dict, airport in
            var dictionary = dict
            dictionary[airport.iata3] = airport
            return dictionary
        }
    }
}
