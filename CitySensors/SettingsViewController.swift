//
//  ViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var airQualitySwitch: UISwitch!
    @IBOutlet weak var beeHiveSwitch: UISwitch!
    @IBOutlet weak var environmentalSwitch: UISwitch!
    @IBOutlet weak var highPrecisionAirMonitorSwitch: UISwitch!
    @IBOutlet weak var riverLevelSwitch: UISwitch!
    @IBOutlet weak var tidalLevelSwitch: UISwitch!
    @IBOutlet weak var trafficSwitch: UISwitch!
    @IBOutlet weak var weatherSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView

        headerView.textLabel?.textColor = .flatWhite
    }
}
