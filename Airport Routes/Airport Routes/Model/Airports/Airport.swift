import CoreLocation

struct Airport: Equatable {
    let name: String
    let city: String
    let country: String
    let iata3: String
    let latitude: Double
    let longitude: Double
    var location: CLLocation? {
        guard let lat = CLLocationDegrees(exactly: latitude),
            let long = CLLocationDegrees(exactly: longitude) else {
                return nil
        }
        return CLLocation(latitude: lat, longitude: long)
    }
    init?(name: String, city: String, country: String, iata3: String, latitude latStr: String, longitude longStr: String) {
        guard let latitude = Double(latStr),
            let longitude = Double(longStr) else {
                return nil
        }
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.city = city
        self.country = country
        self.iata3 = iata3
    }
}
