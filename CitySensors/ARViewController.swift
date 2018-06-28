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
import ChameleonFramework
import CoreLocation
import MapKit
import PKHUD
import SceneKit
import SwifterSwift

class ARViewController: UIViewController {

    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var sensors = [UrbanObservatorySensor]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarStyle(UIStatusBarStyleContrast)
        HUD.show(.progress, onView: self.view)

        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            setupLocationServices()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            showAlert(title: "Location Services", message: "Please enable the location services")
        }

        setupSceneView()
        setupMapView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()
    }

    func setupSceneView() {
        let scene = SCNScene()

        sceneLocationView.scene = scene
        sceneLocationView.showsStatistics = false
        sceneLocationView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }

    func setupMapView() {
        let initialLocation = CLLocation(latitude: Constants.INITIAL_COORDINATES["latitude"]!, longitude: Constants.INITIAL_COORDINATES["longitude"]!)

        mapView.delegate = self
        mapView.cornerRadius = mapView.bounds.height / 10
        mapView.setCenter(on: initialLocation, with: Constants.DEFAULT_RADIUS, animated: true)
        mapView.register(SensorAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }

    func setupLocationServices() {
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestLocation()
    }

    func getSensorReadings(sensor: UrbanObservatorySensor) -> String {
        return sensor.data.reduce("") { (result, entry) in
            guard let currentReading = entry.value.data.first?.value else { return "" }
            let formattedReading = String(format: "%.2f", currentReading)

            return result + "\(entry.key): \(formattedReading) \(entry.value.meta.units)\n"
        }
    }

    func resetSession() {
        sceneLocationView.pause()
        sceneLocationView.run()
    }
}

extension ARViewController {
    @IBAction func closeSettings(_ segue: UIStoryboardSegue) {}
    @IBAction func saveSettings(_ segue: UIStoryboardSegue) {}
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.userLocation = currentLocation

        if mapView.userTrackingMode == .none {
            mapView.userTrackingMode = .followWithHeading
            mapView.setCenter(currentLocation.coordinate, animated: false)
        }

        let parameters = [
            "api_key": APIConfig.API_KEY,
            "buffer": "\(self.userLocation.coordinate.longitude),\(self.userLocation.coordinate.latitude),\(Constants.DEFAULT_RADIUS)",
            "sensor_type": "Air Quality-and-Weather-and-Environmental",
        ]

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            let billboardView: BillboardView = BillboardView.fromNib()
            
            for sensor in self.sensors {
                let sensorImage = UIImage(named: sensor.type)!
                let sensorName = sensor.source.webDisplayName
                let currentReadings = self.getSensorReadings(sensor: sensor)
                let sensorHeight = sensor.baseHeight == -999.0 ? 50.0 : sensor.baseHeight
                let sensorCoordinates = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[1], longitude: sensor.geometry.coordinates[0])
                let sensorAnnotation = SensorAnnotation(title: sensor.type, coordinate: sensorCoordinates, sensorName: sensorName, sensorType: sensor.type, image: sensorImage)

                billboardView.titleLabel.text = sensorName
                billboardView.iconImageView.image = sensorImage
                billboardView.readingsLabel.text = currentReadings

                let location = CLLocation(coordinate: sensorCoordinates, altitude: sensorHeight)
                let billboardImage = billboardView.takeSnapshot()
                let annotationNode = LocationAnnotationNode(location: location, image: billboardImage)

                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                self.mapView.addAnnotation(sensorAnnotation)
            }
        }, onError: { error in
            print(error)

            HUD.hide()
            self.showAlert(title: "Error", message: error.localizedDescription)
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        HUD.hide()
        showAlert(title: "Error", message: error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            setupLocationServices()
        }
    }
}

extension ARViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let sensorAnnotation = annotation as? SensorAnnotation else { return nil }

        let reuseIdentifier = MKMapViewDefaultAnnotationViewReuseIdentifier
        var customAnnotationView = SensorAnnotationView()

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? SensorAnnotationView {
            annotationView.annotation = sensorAnnotation
            customAnnotationView = annotationView
        } else {
            customAnnotationView = SensorAnnotationView(annotation: sensorAnnotation, reuseIdentifier: reuseIdentifier)
        }

        return customAnnotationView
    }
}

extension ARViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)

        if let sessionError = error as? ARError {
            switch sessionError.errorCode {
            case 102:
                sceneLocationView.orientToTrueNorth = false
                resetSession()
            default:
                sceneLocationView.orientToTrueNorth = true
                resetSession()
            }
        }
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
