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

    var userLocation = CLLocation()
    var sensors = [UrbanObservatorySensor]()
    var historicalSensors = [UrbanObservatorySensor]()
    var isSceneReady = false
    var sceneNeedsNodes = true
    var sceneNodes = [SensorNode]()
    var mapAnnotations = [MKAnnotation]()
    var fetchSensorsDataTimer: Timer?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarStyle(UIStatusBarStyleContrast)
        HUD.show(.labeledProgress(title: nil, subtitle: "Fetching Sensors"), onView: self.view)

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            setupLocationServices()
        default:
            showAlert(title: "Location Services", message: "CitySensors requires location services to work correctly")
        }

        setupMapView()
        setupLocationServices()
        setupSceneView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()

        stopFetchTimer()
    }

    // MARK: - Class Methods
    private func addNodesToScene() {
        for sensor in sensors {
            DispatchQueue.main.async {
                let sensorImage = UIImage(named: sensor.type)!
                let sensorName = sensor.source.webDisplayName
                let sensorHeight = sensor.baseHeight < Constants.DEFAULT_SENSOR_HEIGHT
                    ? Constants.DEFAULT_SENSOR_HEIGHT
                    : sensor.baseHeight
                let sensorCoordinates = CLLocationCoordinate2D(latitude: sensor.geometry.coordinates[1], longitude: sensor.geometry.coordinates[0])
                let sensorAnnotation = SensorAnnotation(title: sensor.type, coordinate: sensorCoordinates, sensorName: sensorName, sensorType: sensor.type, image: sensorImage)
                let sensorLocation = CLLocation(coordinate: sensorCoordinates, altitude: sensorHeight)
                let shouldDisplayWaypoint = self.userLocation.distance(from: sensorLocation) > 20
                let sensorNode = SensorNode(location: sensorLocation, sensor: sensor, isWaypoint: shouldDisplayWaypoint)

                for historicalSensor in self.historicalSensors {
                    if sensor.name == historicalSensor.name {
                        sensorNode.historicalSensor = historicalSensor
                    }
                }

                self.startMonitoringGeofence(for: sensorAnnotation, radius: Constants.DEFAULT_GEOFENCE_RADIUS)
                self.sceneNodes.append(sensorNode)
                self.mapAnnotations.append(sensorAnnotation)

                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: sensorNode)
                self.mapView.addAnnotation(sensorAnnotation)
            }
        }
    }

    @objc
    private func fetchHistoricalSensorData() {
        guard var parameters = getBaseParameters() else { return }
        let yesterday = Date().subtract(1.days).start(of: .day)
        parameters["start_time"] = yesterday.format(with: Constants.API_DATE_FORMAT)
        parameters["end_time"] = yesterday.end(of: .day).format(with: Constants.API_DATE_FORMAT)

        ApiHandler.getRawSensorsData(with: parameters, onSuccess: { sensors in
            self.historicalSensors = sensors.sorted(by: { $0.name > $1.name })
            self.fetchLiveSensorsData()
        }, onError: { error in
            print(error)

            HUD.hide()
            self.showAlert(title: "Error", message: "An error ocurred while fetching the sensors data: \(error.localizedDescription)")
        })
    }

    func fetchLiveSensorsData() {
        guard let parameters = getBaseParameters() else { return }

        ApiHandler.getLiveSensorsData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors.sorted(by: { $0.name > $1.name })

            self.removeAllNodes()
            self.addNodesToScene()

            self.stopFetchTimer()
            self.fetchSensorsDataTimer = self.startFetchTimer()

            HUD.hide()
        }, onError: { error in
            print(error)

            HUD.hide()
            self.showAlert(title: "Error", message: "An error occured while fetching live data: \(error.localizedDescription)")
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
            "buffer": "\(userLocation.coordinate.longitude),\(userLocation.coordinate.latitude),\(selectedRadius)",
            "sensor_type": selectedSensors.count > 0 ? selectedSensors.joined(separator: "-and-") : ""
        ]
    }

    @objc
    private func handleSceneViewTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let sceneView = sender.view as! SceneLocationView
            let location = sender.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)

            if !hitResults.isEmpty {
                guard let firstResult = hitResults.first else { return }

                let selectedNode = firstResult.node
                let sensorNode = selectedNode.parent as! SensorNode
                let currentContent = selectedNode.geometry?.firstMaterial?.diffuse.contents as! UIImage

                if sensorNode.historicalSensor != nil {
                    if currentContent == sensorNode.todayImage {
                        selectedNode.geometry?.firstMaterial?.diffuse.contents = sensorNode.historicalImage
                    } else if currentContent == sensorNode.historicalImage {
                        selectedNode.geometry?.firstMaterial?.diffuse.contents = sensorNode.todayImage
                    }
                }
            }
        }
    }

    private func removeAllNodes() {
        for node in sceneNodes {
            sceneLocationView.removeLocationNode(locationNode: node)
        }

        mapView.removeAnnotations(mapAnnotations)
        sceneNodes.removeAll()
        mapAnnotations.removeAll()
        stopMonitoringGeofences(annotations: mapAnnotations)
        mapView.removeAllOverlays()
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
        locationManager.startUpdatingLocation()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.userTrackingMode = .followWithHeading
        mapView.register(SensorMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.cornerRadius = mapView.bounds.height / 10
    }

    private func setupSceneView() {
        let sceneViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleSceneViewTap(sender:)))

        sceneLocationView.locationDelegate = self
        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = true
        sceneLocationView.addGestureRecognizer(sceneViewTapGesture)
    }

    private func startFetchTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(MainViewController.fetchHistoricalSensorData), userInfo: nil, repeats: true)
    }

    private func startMonitoringGeofence(for annotation: MKAnnotation, radius: Double) {
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

    private func stopFetchTimer() {
        guard let timer = fetchSensorsDataTimer else { return }
        timer.invalidate()
    }

    private func stopMonitoringGeofences(annotations: [MKAnnotation]) {
        for annotation in annotations {
            let regionIdentifier = "Geofence-\(annotation.coordinate.latitude)-\(annotation.coordinate.longitude)"

            for region in locationManager.monitoredRegions {
                guard let circularRegion = region as? CLCircularRegion else { return }

                if circularRegion.identifier == regionIdentifier {
                    locationManager.stopMonitoring(for: circularRegion)
                }
            }
        }
    }
}

// MARK: - IBActions Methods
extension MainViewController {
    @IBAction func unwindAndCloseSettings(_ segue: UIStoryboardSegue) {}
    @IBAction func unwindAndSaveSettings(_ segue: UIStoryboardSegue) {
        if isSceneReady {
            HUD.show(.labeledProgress(title: nil, subtitle: "Updating Scene"), onView: self.view)
            fetchHistoricalSensorData()
        }
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if currentLocation.horizontalAccuracy < 100 {
            manager.stopUpdatingLocation()
            userLocation = currentLocation
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region.identifier)")
        if region is CLCircularRegion {
            showAlert(title: "Entered Region", message: "did enter region \(region.identifier)")
            removeAllNodes()
            addNodesToScene()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region.identifier)")
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
        isSceneReady = true
        fetchHistoricalSensorData()
    }

    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {}
}
