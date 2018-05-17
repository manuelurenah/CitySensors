//
//  ViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import PKHUD
import SwifterSwift

class ViewController: UITableViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!

    @IBAction func refreshButtonTap(_ sender: UIBarButtonItem) {
        if CLLocationManager.locationServicesEnabled() {
            HUD.show(.progress, onView: self.navigationController?.view)
            locationManager.requestLocation()
        }
    }

    let locationManager = CLLocationManager()
    var sensors = [Sensor]()
    let cellIdentifier = "SensorCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }

        HUD.show(.progress, onView: self.navigationController?.view)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let sensor = sensors[indexPath.row]
        let mainReading = sensor.data.first
        let detail = "Latest Record: \(sensor.latestReading) - Value: \(String(describing: mainReading!.value.data.first!.value)) \(String(describing: mainReading!.value.meta.units))"

        cell.textLabel?.text = sensor.source.webDisplayName
        cell.detailTextLabel?.text = detail

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? ARViewController,
            let indexPath = self.tableView.indexPathForSelectedRow
        else { return }
        destinationViewController.sensor = sensors[indexPath.row]
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }

        let parameters: Parameters = [
            "api_key": APIConfig.API_KEY,
            "buffer": "\(currentLocation.coordinate.longitude),\(currentLocation.coordinate.latitude),\(Constants.DEFAULT_RADIUS)",
            "sensor_type": ["Environmental", "Traffic", "Weather"].joined(separator: "-and-"),
        ]

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            self.tableView.reloadData()
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
