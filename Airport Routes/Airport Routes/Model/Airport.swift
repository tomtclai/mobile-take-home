import CoreLocation

struct Airport {
    let name: String
    let city: String
    let country: String
    let iata3: String
    let location: CLLocation
    init?(name: String, city: String, country: String, iata3: String, latitude latStr: String, longitude longStr: String) {
        guard let latitude = Double(latStr),
            let longitude = Double(longStr),
            let lat = CLLocationDegrees(exactly: latitude),
            let long = CLLocationDegrees(exactly: longitude) else {
                return nil
        }
        location = CLLocation(latitude: lat, longitude: long)
        self.name = name
        self.city = city
        self.country = country
        self.iata3 = iata3
    }
}
