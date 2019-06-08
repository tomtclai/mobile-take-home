//
//  ViewController.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // to be refactored into something like coordinator
    let airportService = AirportService(csvReader: CSVReader())
    let routeService = RouteService(csvReader: CSVReader())
    let airlineService = AirlineService(csvReader: CSVReader())
    
    var routeManager: RouteManager?
    
    var airports: Airports?
    var airlines: Airlines?
    var routes: Routes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        airlineService.getAirlines { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let airlines):
                sSelf.airlines = airlines
            case .failure(let error):
                print(error)
            }
        }
        routeService.getRoutes { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let routes):
                sSelf.routes = routes
            case .failure(let error):
                print(error)
            }
        }
        airportService.getAirports { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let airports):
                sSelf.airports = airports
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

