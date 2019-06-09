//
//  HomeMapViewModel.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/9/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import Foundation
import MapKit

protocol HomeMapViewModelProtocol {
    func searchForRoutes(origin: String?, destination: String?, successfulClosure: @escaping ([MKOverlay], [MKAnnotation], [String]) -> Void)
    func viewDidLoad()
    
    var resignFirstResponder: EmptyCallBack? { get set }
    var shakeOriginField: EmptyCallBack? { get set }
    var shakeDestinationField: EmptyCallBack? { get set }
    var presentAlert: ((_ title: String, _ message: String) -> Void)? { get set }
    var startSpinner: EmptyCallBack? { get set }
    var stopSpinner: EmptyCallBack? { get set }
    func overlayRenderer(overlay: MKOverlay) -> MKOverlayRenderer
}

class HomeMapViewModel: HomeMapViewModelProtocol {
    let airportService: AirportServiceProtocol
    let routeService: RouteServiceProtocol
    let airlineService: AirlineServiceProtocol
    
    var routeManagerFactory: RouteManagerFactoryProtocol
    var routeManager: RouteManagerProtocol?
    var airports: Airports?
    var airlines: Airlines?
    var routes: Routes?
    
    var resignFirstResponder: EmptyCallBack?
    var shakeOriginField: EmptyCallBack?
    var shakeDestinationField: EmptyCallBack?
    var presentAlert: ((_ title: String, _ message: String) -> Void)?
    var startSpinner: EmptyCallBack?
    var stopSpinner: EmptyCallBack?
    
    init(airportService: AirportServiceProtocol, routeService: RouteServiceProtocol, airlineService: AirlineServiceProtocol, routeManagerFactory: RouteManagerFactoryProtocol) {
        
        self.airportService = airportService
        self.routeService = routeService
        self.airlineService = airlineService
        self.routeManagerFactory = routeManagerFactory
    }
    
    func searchForRoutes(origin: String?, destination: String?, successfulClosure: @escaping ([MKOverlay], [MKAnnotation], [String]) -> Void) {
        guard let routeManager = routeManager else { return }
        resignFirstResponder?()
        guard let origin = origin, !origin.isEmpty else {
            shakeOriginField?()
            presentAlert?(UserStrings.Alert.tryAgain, UserStrings.Alert.typeAirportCode)
            return
        }
        guard let dest = destination, !dest.isEmpty else {
            shakeDestinationField?()
            presentAlert?(UserStrings.Alert.tryAgain,  UserStrings.Alert.typeAirportCode)
            return
        }
        
        startSpinner?()
        routeManager.shortestPathBetween(originCode: origin, destinationCode: dest, completion: { [weak self] result in
            self?.handleShortestPathResult(origin: origin, dest: dest, result: result, successfulClosure: successfulClosure)
            }
        )
    }
    
    private func handleShortestPathResult(origin: String, dest: String, result: Result<[Route], RouteManagerError>, successfulClosure: @escaping ([MKOverlay], [MKAnnotation], [String]) -> Void) {
        switch result {
        case .failure(let reason):
            switch reason {
            case .noRoutes, .dataSourceError:
                presentAlert?(UserStrings.Alert.sorry, UserStrings.Alert.weCouldntFindARoute(between: origin, and: dest))
            case .noSuchAirport(let airport):
                presentAlert?(UserStrings.Alert.weCouldntFindThisAirport(airport), UserStrings.Alert.tryAgain)
            case .unwrappingError:
                presentAlert?(UserStrings.Alert.somethingWentWrong, UserStrings.Alert.tryAgain)
            }
        case .success(let paths):
            let airports = convertRouteToAirports(route: paths)
            let airportCodes = airports.map {$0.iata3}
            print(airportCodes.joined(separator: " » ") )
            let overlays = convertAirportsToMapLines(airports: airports)
            let annotations = convertAirportsToAnnotations(airports: airports)
            successfulClosure(overlays, annotations, airports.map {$0.iata3})
        }
        stopSpinner?()
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
    
    private func convertAirportsToMapLines(airports: [Airport]) -> [MKOverlay] {
        let points = airports.compactMap { $0.location?.coordinate }
        var geodesic = [MKGeodesicPolyline]()
        for i in 1..<points.count {
            geodesic.append(MKGeodesicPolyline(coordinates: [points[i-1], points[i]], count: 2))
        }
        return geodesic
    }
    
    private func convertAirportsToAnnotations(airports: [Airport]) -> [MKAnnotation] {
        return airports.enumerated().compactMap{ index, airport in
            guard let coordinate = airport.location?.coordinate else { return nil }
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(index+1). \(airport.name) (\(airport.iata3))"
            annotation.subtitle = "\(airport.city), \(airport.country)"
            return annotation
        }
    }
    
    func viewDidLoad() {
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
        routeManager = routeManagerFactory.makeRouteManager(routes: routes, airports: airports)
    }
    
    func overlayRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 2
        renderer.lineJoin = .round
        renderer.lineCap = .round
        return renderer
    }
    
}
