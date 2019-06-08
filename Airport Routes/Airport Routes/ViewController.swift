//
//  ViewController.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
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
        routeManager.shortestPathBetween(originCode: origin, destinationCode: dest, completion: { result in
            switch result {
            case .failure(let reason):
                switch reason {
                case .noRoutes:
                    presentAlert(title: UserStrings.Alert.sorry, message: UserStrings.Alert.weCouldntFindARoute(between: origin, and: dest))
                case .noSuchAirport(let airport):
                    presentAlert(title: UserStrings.Alert.weCouldntFindThisAirport(airport), message: UserStrings.Alert.tryAgain)
                case .unwrappingError:
                    presentAlert(title: UserStrings.Alert.somethingWentWrong, message: UserStrings.Alert.tryAgain)
                }
            case .success(let paths):
                print(paths)
            }
        })
    }
    
    // IBActions
    
    
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
