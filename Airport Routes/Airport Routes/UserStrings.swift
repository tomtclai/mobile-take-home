enum UserStrings {
    enum Screens {
        static let flightRoutes = "Flight Routes"
    }
    enum Alert {
        static let somethingWentWrong = "Something went wrong..."
        static let tryAgain = "Please try again"
        static let typeAirportCode = "Please type the airport code"
        static let okay = "Okay"
        static let sorry = "Sorry..."
        static func weCouldntFindARoute(between orig: String, and dest: String) -> String {
            return "We couldn't find a route between \(orig) and \(dest)"
        }
        static func weCouldntFindThisAirport(_ airport: String) -> String {
            return "We couldn't find this airport: \(airport)"
        }
    }
}
