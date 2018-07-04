//
//  TestViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 7/3/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import CoreLocation

import HDAugmentedReality

class TestViewController: ARViewController {

    let locationManager = CLLocationManager()
    var isLoadingPointsOfInterest = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupARViewController() {
        self.dataSource = self
        self.presenter.maxDistance = 100
        self.presenter.maxVisibleAnnotations = 10
        self.presenter.distanceOffsetMode = .automatic
        self.presenter.presenterTransform = ARPresenterStackTransform()

        self.trackingManager.userDistanceFilter = 25
        self.trackingManager.reloadDistanceFilter = 75

        self.interfaceOrientationMask = .portrait
    }

    func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TestViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if currentLocation.horizontalAccuracy <= 100 {
            let parameters = [
                "api_key": APIConfig.API_KEY,
                "buffer": "\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude),\(Constants.DEFAULT_RADIUS)",
                "sensor_type": "Air Quality-and-Weather-and-Environmental",
            ]

            ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            }, onError: { error in
                print(error)
            })
        }
    }
}

extension TestViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        return ARAnnotationView()
    }
}
