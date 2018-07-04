//
//  ARViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/16/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import ARKit
import UIKit
import CoreLocation
import MapKit
import SceneKit

import ARCL
import ChameleonFramework
import PKHUD
import SwifterSwift
import UIImageColors

class MainViewController: UIViewController {

    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var mapView: MKMapView!

    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var sensors = [UrbanObservatorySensor]()
    var isSceneReady = false
    var sceneNeedsNodes = true

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
        mapView.register(SensorMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.cornerRadius = mapView.bounds.height / 10
        mapView.centerMap(on: initialLocation, with: Double(Constants.DEFAULT_RADIUS), animated: false)
    }

    func setupLocationServices() {
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
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

extension MainViewController {
    @IBAction func unwindAndCloseSettings(_ segue: UIStoryboardSegue) {}
    @IBAction func unwindAndSaveSettings(_ segue: UIStoryboardSegue) {}
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if mapView.userTrackingMode == .none {
            mapView.userTrackingMode = .followWithHeading
            mapView.centerMap(on: currentLocation, with: Double(Constants.DEFAULT_RADIUS))
        }

        if currentLocation.horizontalAccuracy <= 100 {
            manager.stopUpdatingLocation()
            self.userLocation = currentLocation

            let selectedRadius = userDefaults.integer(forKey: Constants.KEY_RADIUS) == 0
                ? Constants.DEFAULT_RADIUS
                : userDefaults.integer(forKey: Constants.KEY_RADIUS)

            let parameters = [
                "api_key": APIConfig.API_KEY,
                "buffer": "\(self.userLocation.coordinate.longitude),\(self.userLocation.coordinate.latitude),\(selectedRadius)",
                "sensor_type": "Air Quality-and-Weather-and-Environmental",
            ]

            ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
                self.sensors = sensors
                HUD.hide()

                var annotationImage = UIImage()

                for sensor in self.sensors {
                    let sensorImage = UIImage(named: sensor.type)!
                    let sensorName = sensor.source.webDisplayName
                    let currentReadings = self.getSensorReadings(sensor: sensor)
                    let sensorHeight = sensor.baseHeight <= 0 ? 50.0 : sensor.baseHeight
                    let sensorCoordinates = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[1], longitude: sensor.geometry.coordinates[0])
                    let sensorAnnotation = SensorAnnotation(title: sensor.type, coordinate: sensorCoordinates, sensorName: sensorName, sensorType: sensor.type, image: sensorImage)
                    let sensorLocation = CLLocation(coordinate: sensorCoordinates, altitude: sensorHeight)

                    if self.userLocation.distance(from: sensorLocation) <= 30.0 {
                        let billboardView: BillboardView = BillboardView.fromNib()

                        billboardView.titleLabel.text = sensorName
                        billboardView.sensorType = sensor.type
                        billboardView.iconImageView.image = sensorImage
                        billboardView.readingsLabel.text = currentReadings

                        annotationImage = billboardView.takeSnapshot()
                    } else {
                        let waypointView: WaypointView = WaypointView.fromNib()

                        waypointView.sensorType = sensor.type
                        waypointView.iconImageView.image = sensorImage

                        annotationImage = waypointView.takeSnapshot()
                    }

                    let annotationNode = LocationAnnotationNode(location: sensorLocation, image: annotationImage)

                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                    self.mapView.addAnnotation(sensorAnnotation)
                }
            }, onError: { error in
                print(error)

                HUD.hide()
                self.showAlert(title: "Error", message: error.localizedDescription)
            })
        }
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

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let sensorAnnotation = annotation as? SensorAnnotation else { return nil }

        let reuseIdentifier = MKMapViewDefaultAnnotationViewReuseIdentifier
        var customAnnotationView = SensorMarkerView()

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? SensorMarkerView {
            annotationView.annotation = sensorAnnotation
            customAnnotationView = annotationView
        } else {
            customAnnotationView = SensorMarkerView(annotation: sensorAnnotation, reuseIdentifier: reuseIdentifier)
        }

        return customAnnotationView
    }
}

extension MainViewController: ARSCNViewDelegate {
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

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            isSceneReady = true
        default:
            isSceneReady = false
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
