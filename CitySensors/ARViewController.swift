//
//  ARViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/16/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import ARCL
import ARKit
import CoreLocation
import PKHUD
import SceneKit
import SwifterSwift

class ARViewController: UIViewController {

    @IBOutlet weak var sceneLocationView: SceneLocationView!

    let locationManager = CLLocationManager()
    var sensors = [Sensor]()

    override func viewDidLoad() {
        super.viewDidLoad()

        HUD.show(.progress, onView: self.view)

        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpSceneView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()
    }

    func setUpSceneView() {

        sceneLocationView.run()
    }
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }

        let parameters = [
            "api_key": APIConfig.API_KEY,
            "buffer": "\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude),\(Constants.DEFAULT_RADIUS)",
            "sensor_type": ["Environmental", "Traffic", "Weather"].joined(separator: "-and-"),
        ]

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            for sensor in self.sensors {
                let coordinate = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[0], longitude: sensor.geometry.coordinates[1])
                let location = CLLocation(coordinate: coordinate, altitude: 300)
                let sensorImage = UIImage(named: sensor.type)!
                let annotationNode = LocationAnnotationNode(location: location, image: sensorImage)

                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
        }, onError: { error in
            let alertController = UIAlertController(title: "Unexpected Error", message: "An Unexpected error occurred, please try again", defaultActionButtonTitle: "Ok", tintColor: UIColor.blue)

            HUD.hide()
            alertController.show(animated: true, vibrate: false, completion: nil)

            print(error)
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension SCNNode {
    func center() {
        let (min, max) = self.boundingBox

        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        self.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
}
