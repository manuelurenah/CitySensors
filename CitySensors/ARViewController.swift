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
    var userLocation = CLLocation()
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

        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()
    }

    func getSensorReadings(sensor: Sensor) -> String {
        return sensor.data.reduce("") { (result, entry) in
            guard let currentReading = entry.value.data.first?.value else { return "" }
            let formattedReading = String(format: "%.2f", currentReading)

            return result + "\(entry.key): \(formattedReading) \(entry.value.meta.units)\n"
        }
    }
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.userLocation = currentLocation

        let parameters = [
            "api_key": APIConfig.API_KEY,
            "buffer": "\(self.userLocation.coordinate.longitude),\(self.userLocation.coordinate.latitude),\(Constants.DEFAULT_RADIUS)",
            "sensor_type": "Weather",
        ]

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            for sensor in self.sensors {
                let sensorHeight = sensor.baseHeight == -999.0 ? 1.0 : sensor.baseHeight
                let coordinate = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[1], longitude: sensor.geometry.coordinates[0])
                let location = CLLocation(coordinate: coordinate, altitude: sensorHeight)
                let sensorImage = UIImage(named: sensor.type)!
                let annotationNode = LocationAnnotationNode(location: location, image: sensorImage)

                let sensorTitleGeometry = SCNText(string: sensor.source.webDisplayName, extrusionDepth: 0.01)
                sensorTitleGeometry.font = UIFont(name: "San Francisco", size: 10)

                let sensorTitleNode = SCNNode(geometry: sensorTitleGeometry)
                sensorTitleNode.center()
                sensorTitleNode.position = SCNVector3(0, annotationNode.boundingBox.max.y, 0)
                sensorTitleNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)

                let currentReadings = self.getSensorReadings(sensor: sensor)
                let sensorReadingGeometry = SCNText(string: currentReadings, extrusionDepth: 0.01)
                sensorReadingGeometry.font = UIFont(name: "San Francisco", size: 10)

                let sensorReadingNode = SCNNode(geometry: sensorReadingGeometry)
                sensorReadingNode.position = SCNVector3(x: annotationNode.boundingBox.max.x, y: 0, z: 0.5)
                sensorReadingNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)

                annotationNode.addChildNode(sensorTitleNode)
                annotationNode.addChildNode(sensorReadingNode)

                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
        }, onError: { error in
            HUD.hide()

            let alertController = UIAlertController(error: error)
            alertController.show()
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        HUD.hide()

        let alertController = UIAlertController(error: error)
        alertController.show()
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
