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
import DateToolsSwift
import PKHUD
import SwifterSwift
import UIImageColors

class MainViewController: UIViewController {

    // MARK: - IBOutlets Properties
    @IBOutlet weak var sceneLocationView: SceneLocationView!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Class Properties
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var sensors = [UrbanObservatorySensor]()
    var lastDaySensors = [UrbanObservatorySensor]()
    var isSceneReady = false
    var sceneNeedsNodes = true
    var sceneNodes = [LocationNode]()
    var mapAnnotations = [MKAnnotation]()
    var fetchSensorsDataTimer: Timer?
    let sensorKeys = [
        UserSettingsKeys.AIR_QUALITY,
        UserSettingsKeys.BEE_HIVE,
        UserSettingsKeys.ENVIRONMENTAL,
        UserSettingsKeys.HIGH_PRECISION_AIR_MONITOR,
        UserSettingsKeys.RIVER_LEVEL,
        UserSettingsKeys.TIDAL_LEVEL,
        UserSettingsKeys.TRAFFIC,
        UserSettingsKeys.WEATHER,
    ]

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarStyle(UIStatusBarStyleContrast)
        HUD.show(.progress, onView: self.view)

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            setupLocationServices()
        default:
            showAlert(title: "Location Services", message: "CitySensors requires location services to work correctly")
        }

        setupSceneView()
        setupMapView()
        setupLocationServices()

        getLastDayReadings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneLocationView.run()
        fetchSensorsDataTimer = startFetchTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()

        guard let timer = fetchSensorsDataTimer else { return }
        timer.invalidate()
    }

    // MARK: - Class Methods
    private func addNodesToScene() {
        for sensor in self.sensors {
            DispatchQueue.main.async {
                let sensorImage = UIImage(named: sensor.type)!
                let sensorName = sensor.source.webDisplayName
                let sensorHeight = sensor.baseHeight < Constants.DEFAULT_SENSOR_HEIGHT
                    ? Constants.DEFAULT_SENSOR_HEIGHT
                    : sensor.baseHeight
                let sensorCoordinates = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[1], longitude: sensor.geometry.coordinates[0])
                let sensorAnnotation = SensorAnnotation(title: sensor.type, coordinate: sensorCoordinates, sensorName: sensorName, sensorType: sensor.type, image: sensorImage)
                let sensorLocation = CLLocation(coordinate: sensorCoordinates, altitude: sensorHeight)
                let shouldDisplayWaypoint = self.userLocation.distance(from: sensorLocation) > 100
                let annotationNode = SensorNode(location: sensorLocation, sensor: sensor, asWaypoint: shouldDisplayWaypoint)

                self.addRegionAndOverlay(for: sensorAnnotation, radius: Constants.DEFAULT_GEOFENCE_RADIUS)
                self.sceneNodes.append(annotationNode)
                self.mapAnnotations.append(sensorAnnotation)

                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                self.mapView.addAnnotation(sensorAnnotation)
            }
        }
    }

    private func addRegionAndOverlay(for annotation: MKAnnotation, radius: Double) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(title:"Error", message: "Geofencing is not supported on this device!")
            return
        }

        let region = CLCircularRegion(center: annotation.coordinate, radius: radius, identifier: "Geofence-\(annotation.coordinate.latitude)-\(annotation.coordinate.longitude)")
        region.notifyOnExit = true
        region.notifyOnEntry = true

        mapView.add(MKCircle(center: annotation.coordinate, radius: radius))
        locationManager.startMonitoring(for: region)
    }

    @objc func fetchSensorsData() {
        guard let parameters = getBaseParameters() else { return }

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            self.removeAllNodes()
            self.addNodesToScene()
        }, onError: { error in
            print(error)

            HUD.hide()
            self.showAlert(title: "Error", message: error.localizedDescription)
        })
    }

    private func getBaseParameters() -> [String: Any]? {
        let selectedRadius = userDefaults.integer(forKey: Constants.KEY_RADIUS) == 0
            ? Constants.DEFAULT_RADIUS
            : userDefaults.integer(forKey: Constants.KEY_RADIUS)

        var selectedSensors = [String]()
        for key in sensorKeys {
            let isSelected = userDefaults.bool(forKey: key)

            if isSelected {
                selectedSensors.append(key)
            }
        }

        guard let currentLocation = locationManager.location else { return nil }
        userLocation = currentLocation

         return [
            "api_key": APIConfig.API_KEY,
            "buffer": "\(userLocation.coordinate.longitude),\(userLocation.coordinate.latitude),\(selectedRadius)",
            "sensor_type": selectedSensors.count > 0 ? selectedSensors.joined(separator: "-and-") : ""
        ]
    }

    private func getLastDayReadings() {
        guard var parameters = getBaseParameters() else { return }
        let yesterday = Date().subtract(1.days).start(of: .day)
        parameters["start_time"] = yesterday.format(with: Constants.API_DATE_FORMAT)
        parameters["end_time"] = yesterday.end(of: .day).format(with: Constants.API_DATE_FORMAT)

        ApiHandler.getSensorsData(with: parameters, onSuccess: { sensors in
            self.lastDaySensors = sensors
            sensors.forEach { sensor in
                let averageReadings = sensor.getAverageReadings()
                print(sensor.getReadings(values: averageReadings))
            }
        }, onError: { error in
            print(error)
        })
    }

    private func removeAllNodes() {
        stopMonitoringRegions(annotations: mapAnnotations)
        mapView.removeAllOverlays()

        for node in sceneNodes {
            sceneLocationView.removeLocationNode(locationNode: node)
        }

        mapView.removeAnnotations(mapAnnotations)
        sceneNodes.removeAll()
        mapAnnotations.removeAll()
    }

    private func resetSession() {
        sceneLocationView.pause()
        sceneLocationView.run()
    }

    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.userTrackingMode = .followWithHeading
        mapView.register(SensorMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.cornerRadius = mapView.bounds.height / 10
    }

    private func setupSceneView() {
        sceneLocationView.locationDelegate = self
        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = true
    }

    private func startFetchTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MainViewController.fetchSensorsData), userInfo: nil, repeats: true)
    }

    private func stopMonitoringRegions(annotations: [MKAnnotation]) {
        for annotation in annotations {
            let regionIdentifier = "Geofence-\(annotation.coordinate.latitude)-\(annotation.coordinate.longitude)"

            for region in locationManager.monitoredRegions {
                guard let circularRegion = region as? CLCircularRegion,
                    circularRegion.identifier == regionIdentifier
                    else { return }

                locationManager.stopMonitoring(for: circularRegion)
            }
        }
    }
}

// MARK: - IBActions Methods
extension MainViewController {
    @IBAction func unwindAndCloseSettings(_ segue: UIStoryboardSegue) {}

    @IBAction func unwindAndSaveSettings(_ segue: UIStoryboardSegue) {
        removeAllNodes()
        fetchSensorsData()
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            setupLocationServices()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlert(title: "Location Services", message: "CitySensors requires location services to work correctly")
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            showAlert(title: "Entered Region", message: "did enter region \(region.identifier)")
            removeAllNodes()
            addNodesToScene()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            showAlert(title: "Exited Region", message: "did exit region \(region.identifier)")
            removeAllNodes()
            addNodesToScene()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        HUD.hide()
        showAlert(title: "Error", message: "An error ocurred while setting the location services: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        mapView.removeAllOverlays()
        showAlert(title: "Error", message: "An error ocurred while setting the region: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let sensorAnnotation = annotation as? SensorAnnotation else { return nil }

        let reuseIdentifier = MKMapViewDefaultAnnotationViewReuseIdentifier
        var customAnnotationView = MKAnnotationView()

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? SensorMarkerView {
            annotationView.annotation = sensorAnnotation
            customAnnotationView = annotationView
        } else {
            customAnnotationView = MKAnnotationView(annotation: sensorAnnotation, reuseIdentifier: reuseIdentifier)
        }

        return customAnnotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)

            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)

            return circleRenderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MainViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}

    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}

    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {}

    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        guard let currentPosition = sceneLocationView.currentLocation() else { return }
        showAlert(title: "Current Position", message: "\(currentPosition)")
        fetchSensorsData()
    }

    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {}
}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        showAlert(title: "Error", message: "An error ocurred while setting the AR session: \(error.localizedDescription)")

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
