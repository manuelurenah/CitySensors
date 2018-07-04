//
//  ViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit

// MARK: - Class Protocol
protocol SettingsViewControllerDelegate {
    func didToggleSwitch(on: Bool, key: String)
    func didChangeSlider(value: Int)
}

class SettingsViewController: UITableViewController {

    // MARK: - IBOutlets properties
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var airQualitySwitch: UISwitch!
    @IBOutlet weak var beeHiveSwitch: UISwitch!
    @IBOutlet weak var environmentalSwitch: UISwitch!
    @IBOutlet weak var highPrecisionAirMonitorSwitch: UISwitch!
    @IBOutlet weak var riverLevelSwitch: UISwitch!
    @IBOutlet weak var tidalLevelSwitch: UISwitch!
    @IBOutlet weak var trafficSwitch: UISwitch!
    @IBOutlet weak var weatherSwitch: UISwitch!
    @IBOutlet weak var radiusValueLabel: UILabel!

    // MARK: - Class Properties
    let userDefaults = UserDefaults.standard
    var settingsContainerViewController: SettingsContainerViewController!
    var delegate: SettingsViewControllerDelegate? = nil
    var selectedRadius = Constants.DEFAULT_RADIUS
    var selectedSensorTypes = UserSettingsKeys.INITIAL_SETUP

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSettings()

        radiusValueLabel.text = "\(selectedRadius) meters"
    }

    // MARK: - Class Methods
    func setupSettings() {
        radiusSlider.value = Float(selectedRadius)

        airQualitySwitch.setOn(selectedSensorTypes[UserSettingsKeys.AIR_QUALITY]!, animated: false)
        beeHiveSwitch.setOn(selectedSensorTypes[UserSettingsKeys.BEE_HIVE]!, animated: false)
        environmentalSwitch.setOn(selectedSensorTypes[UserSettingsKeys.ENVIRONMENTAL]!, animated: false)
        highPrecisionAirMonitorSwitch.setOn(selectedSensorTypes[UserSettingsKeys.HIGH_PRECISION_AIR_MONITOR]!, animated: false)
        riverLevelSwitch.setOn(selectedSensorTypes[UserSettingsKeys.RIVER_LEVEL]!, animated: false)
        tidalLevelSwitch.setOn(selectedSensorTypes[UserSettingsKeys.TIDAL_LEVEL]!, animated: false)
        trafficSwitch.setOn(selectedSensorTypes[UserSettingsKeys.TRAFFIC]!, animated: false)
        weatherSwitch.setOn(selectedSensorTypes[UserSettingsKeys.WEATHER]!, animated: false)
    }
}

// MARK: - IBActions
extension SettingsViewController {
    @IBAction func radiusSliderValueChanged(_ sender: UISlider) {
        let roundedValue = Int(sender.value)
        radiusValueLabel.text = "\(roundedValue) meters"

        if let delegate = self.delegate {
            delegate.didChangeSlider(value: roundedValue)
        }
    }

    @IBAction func airQualitySwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.AIR_QUALITY)
        }
    }

    @IBAction func beeHiveSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.BEE_HIVE)
        }
    }

    @IBAction func environmentalSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.ENVIRONMENTAL)
        }
    }

    @IBAction func highPrecisionAirMonitorSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.HIGH_PRECISION_AIR_MONITOR)
        }
    }

    @IBAction func riverLevelSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.RIVER_LEVEL)
        }
    }

    @IBAction func tidalLevelSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.TIDAL_LEVEL)
        }
    }

    @IBAction func trafficSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.TRAFFIC)
        }
    }

    @IBAction func weatherSwitched(_ sender: UISwitch) {
        if let delegate = self.delegate {
            delegate.didToggleSwitch(on: sender.isOn, key: UserSettingsKeys.WEATHER)
        }
    }
}
