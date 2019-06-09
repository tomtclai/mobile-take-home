//
//  RouteManagerFactory.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/9/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import Foundation
protocol RouteManagerFactoryProtocol {
    func makeRouteManager(routes: Routes, airports: Airports) -> RouteManagerProtocol
}
class RouteManagerFactory: RouteManagerFactoryProtocol {
    func makeRouteManager(routes: Routes, airports: Airports) -> RouteManagerProtocol {
        return RouteManager(routes: routes, airports: airports)
    }
}
