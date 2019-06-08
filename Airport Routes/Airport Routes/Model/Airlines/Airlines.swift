struct Airlines {
    let by2DigitCode: [String: Airline]
    init(airlines: [Airline]) {
        by2DigitCode = airlines.reduce([String: Airline]()) { dict, airline in
            var dictionary = dict
            dictionary[airline.code2Digit] = airline
            return dictionary
        }
    }
}
