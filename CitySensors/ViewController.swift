//
//  ViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ViewController: UITableViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!

    var sensors = [Sensor]()
    let cellIdentifier = "SensorCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        HUD.show(.progress, onView: self.tableView)

        let parameters: Parameters = [
            "api_key": APIConfig.API_KEY,
        ]

        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            self.sensors = sensors
            HUD.hide()

            self.tableView.reloadData()
        }, onError: { error in
            print(error)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        cell.textLabel?.text = sensor.source.fancyName
        cell.detailTextLabel?.text = detail

        return cell
    }
}
