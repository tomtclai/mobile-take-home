//
//  ViewController.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    // to be refactored into something for dependency injection
    let airportService = AirportService(csvReader: CSVReader())
    let routeService = RouteService(csvReader: CSVReader())
    let airlineService = AirlineService(csvReader: CSVReader())
    
    // to be refactored into view model
    var routeManager: RouteManager?
    var airports: Airports?
    var airlines: Airlines?
    var routes: Routes?
    
    @IBOutlet weak var originField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        mapView.delegate = self
    }
    
    // IBActions
    @IBAction func searchTapped() {
        guard let routeManager = routeManager else { return }
        guard let origin = originField.text, !origin.isEmpty else {
                originField.shake()
                presentAlert(title: UserStrings.Alert.tryAgain, message: UserStrings.Alert.typeAirportCode)
                return
        }
        guard let dest = destinationField.text, !dest.isEmpty else {
                destinationField.shake()
                presentAlert(title: UserStrings.Alert.tryAgain, message: UserStrings.Alert.typeAirportCode)
                return
        }
        
        spinner.startAnimating()
        routeManager.shortestPathBetween(originCode: origin, destinationCode: dest, completion: { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .failure(let reason):
                switch reason {
                case .noRoutes, .dataSourceError:
                    sSelf.presentAlert(title: UserStrings.Alert.sorry, message: UserStrings.Alert.weCouldntFindARoute(between: origin, and: dest))
                case .noSuchAirport(let airport):
                    self?.presentAlert(title: UserStrings.Alert.weCouldntFindThisAirport(airport), message: UserStrings.Alert.tryAgain)
                case .unwrappingError:
                    sSelf.presentAlert(title: UserStrings.Alert.somethingWentWrong, message: UserStrings.Alert.tryAgain)
                }
            case .success(let paths):
                let airports = sSelf.convertRouteToAirports(route: paths)
                print(airports)
                sSelf.drawLinesOnMap(airports: airports)
            }
            sSelf.spinner.stopAnimating()
        })
    }
    var lastOverlay: [MKOverlay]?
    private func drawLinesOnMap(airports: [Airport]){
        let points = airports.compactMap { $0.location?.coordinate }
        
        var geodesic = [MKGeodesicPolyline]()
        for i in 1..<points.count {
            geodesic.append(MKGeodesicPolyline(coordinates: [points[i-1], points[i]], count: 2))
        }
        
        if let lastOverlay = lastOverlay {
            mapView.removeOverlays(lastOverlay)
        }
        mapView.addOverlays(geodesic, level: .aboveRoads)
        let latA = points[0].latitude
        let latB = points[points.count-1].latitude
        let longA = points[0].longitude
        let longB = points[points.count-1].longitude
        let latDelta = latA - latB
        let longDelta = longA - longB
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let sSelf = self else { return }
            let span = MKCoordinateSpan(latitudeDelta: abs(latDelta)+20, longitudeDelta: abs(longDelta)+20)
            let region = MKCoordinateRegion(center: sSelf.midpoint(points[0], points[points.count-1]), span: span)
            sSelf.mapView.setRegion(region, animated: true)
        }
        lastOverlay = geodesic
    }
    
    private func midpoint(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let longA = a.longitude * Double.pi / 180
        let longB = b.longitude * Double.pi / 180
        
        let latA = a.latitude * Double.pi / 180
        let latB = b.latitude * Double.pi / 180
        
        let deltaLong = longB - longA
        let x = cos(latB) * cos(deltaLong)
        let y = cos(latB) * sin(deltaLong)
        
        let lat3 = atan2( sin(latA) + sin(latB), sqrt((cos(latA) + x) * (cos(latA) + x) + y * y) )
        let long3 = longA + atan2(y, cos(latA) + x)
        
        return CLLocationCoordinate2D(latitude: lat3 * 180 / Double.pi, longitude: long3 * 180 / Double.pi)
        
    }
    
    private func convertRouteToAirports(route: [Route]) -> [Airport] {
        guard let airports = airports,
            let firstRoute = route.first,
            let firstAirport = airports.byAirportCode[firstRoute.origin] else {
                print("Couldnt find the first airport in route")
            return []
        }
        var airportList = [firstAirport]
        for i in 0..<route.count {
            guard let airport = airports.byAirportCode[route[i].destination] else { return [] }
            airportList.append(airport)
        }
        return airportList
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mapView.delegate = nil
    }
    
    
    private func loadData() {
        let group = DispatchGroup()
        group.enter()
        airlineService.getAirlines { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let airlines):
                sSelf.airlines = airlines
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        group.enter()
        routeService.getRoutes { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let routes):
                sSelf.routes = routes
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        group.enter()
        airportService.getAirports { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let airports):
                sSelf.airports = airports
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        group.wait()
        guard let routes = routes, let airports = airports else { return }
        routeManager = RouteManager(routes: routes, airports: airports)
    }
}

private extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

private extension UIViewController {
    func presentAlert(title: String, message: String, action actionStr: String = UserStrings.Alert.okay) {
        let action = UIAlertAction(title: actionStr, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 2
        renderer.lineJoin = .round
        renderer.lineCap = .round
        return renderer
    }
}
