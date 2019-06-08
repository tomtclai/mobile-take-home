struct Airports {
    let allAirports: [Airport]
    let byAirportCode: [String: Airport]
    init(airports: [Airport]) {
        allAirports = airports
        byAirportCode = airports.reduce([String: Airport]()) { dict, airport in
            var dictionary = dict
            dictionary[airport.iata3] = airport
            return dictionary
        }
    }
}
