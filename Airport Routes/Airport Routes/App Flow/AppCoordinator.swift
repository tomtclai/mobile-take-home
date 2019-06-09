//
//  AppCoordinator.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/9/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit

class AppCoordinator {
    let navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHomeScreen()
    }
    
    private func showHomeScreen() {
        guard let viewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeMapViewController.className) as? HomeMapViewController else {
            assertionFailure("Cannot instantiate HomeMapViewController")
            return
        }
        let csvReader = CSVReader()
        let airportService = AirportService(csvReader: csvReader)
        let routeService = RouteService(csvReader: csvReader)
        let airlineService = AirlineService(csvReader: csvReader)
        let viewModel = HomeMapViewModel(airportService: airportService, routeService: routeService, airlineService: airlineService)
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: false)
        
    }
}
