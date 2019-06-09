//
//  ViewController.swift
//  Airport Routes
//
//  Created by Tom Lai on 6/8/19.
//  Copyright © 2019 Tom Lai. All rights reserved.
//

import UIKit
import MapKit

class HomeMapViewController: UIViewController {
    
    static var className: String {
        return String(describing: self)
    }
    
    // The viewController cannot work without VM, this is mandatory
    var viewModel: HomeMapViewModelProtocol!
    @IBOutlet weak var originField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = UserStrings.Screens.flightRoutes
        viewModel.viewDidLoad()
        mapView.delegate = self
        setupViewModel()
    }

    private func setupViewModel() {
        viewModel.resignFirstResponder = { [weak self] in
            self?.resigneFirstResponder()
        }
        viewModel.shakeOriginField = { [weak self] in
            self?.originField.shake()
        }
        viewModel.shakeDestinationField = { [weak self] in
            self?.destinationField.shake()
        }
        viewModel.presentAlert = { [weak self] title, message in
            self?.presentAlert(title: title, message: message)
        }
        viewModel.startSpinner = { [weak self] in
            self?.spinner.startAnimating()
        }
        viewModel.stopSpinner = { [weak self] in
            self?.spinner.stopAnimating()
        }
    }
    
    // IBActions
    @IBAction func searchTapped() {
        viewModel.searchForRoutes(origin: originField.text, destination: destinationField.text, successfulClosure: { [weak self] overlays in
            self?.addOverlaysToMap(overlays: overlays)
        })
    }
    
    var lastOverlay: [MKOverlay]?
    private func addOverlaysToMap(overlays: [MKOverlay]) {
        if let lastOverlay = lastOverlay {
            mapView.removeOverlays(lastOverlay)
        }
        mapView.addOverlays(overlays, level: .aboveRoads)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let sSelf = self else { return }
            
            let lineRect = overlays.reduce(overlays[0].boundingMapRect, { $0.union($1.boundingMapRect) })
            sSelf.mapView.setVisibleMapRect(lineRect, animated: true)
        }
        lastOverlay = overlays
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        mapView.delegate = nil
    }
    
    private func resigneFirstResponder() {
        originField.resignFirstResponder()
        destinationField.resignFirstResponder()
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

extension HomeMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return viewModel.overlayRenderer(overlay: overlay)
    }
}
