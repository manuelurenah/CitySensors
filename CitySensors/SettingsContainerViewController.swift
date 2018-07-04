//
//  SettingsContainerViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/31/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsContainerViewController: UIViewController {

    // MARK: - IBOutlets Properties
    @IBOutlet weak var navigationBar: UINavigationBar!

    // MARK: - Class Properties
    let userDefaults = UserDefaults.standard
    var selectedRadius = Constants.DEFAULT_RADIUS
    var selectedSensorTypes = UserSettingsKeys.INITIAL_SETUP

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarStyle(UIStatusBarStyleContrast)

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        loadStoredSettings()
    }

    // MARK: - Class Methods
    func loadStoredSettings() {
        selectedRadius = userDefaults.integer(forKey: Constants.KEY_RADIUS)
        selectedSensorTypes[UserSettingsKeys.AIR_QUALITY] = userDefaults.bool(forKey: UserSettingsKeys.AIR_QUALITY)
        selectedSensorTypes[UserSettingsKeys.BEE_HIVE] = userDefaults.bool(forKey: UserSettingsKeys.BEE_HIVE)
        selectedSensorTypes[UserSettingsKeys.ENVIRONMENTAL] = userDefaults.bool(forKey: UserSettingsKeys.ENVIRONMENTAL)
        selectedSensorTypes[UserSettingsKeys.HIGH_PRECISION_AIR_MONITOR] = userDefaults.bool(forKey: UserSettingsKeys.HIGH_PRECISION_AIR_MONITOR)
        selectedSensorTypes[UserSettingsKeys.RIVER_LEVEL] = userDefaults.bool(forKey: UserSettingsKeys.RIVER_LEVEL)
        selectedSensorTypes[UserSettingsKeys.TIDAL_LEVEL] = userDefaults.bool(forKey: UserSettingsKeys.TIDAL_LEVEL)
        selectedSensorTypes[UserSettingsKeys.TRAFFIC] = userDefaults.bool(forKey: UserSettingsKeys.TRAFFIC)
        selectedSensorTypes[UserSettingsKeys.WEATHER] = userDefaults.bool(forKey: UserSettingsKeys.WEATHER)
    }
}

// MARK: - UINavigation
extension SettingsContainerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EmbeddedSettingsSegue":
            let settingViewController = segue.destination as! SettingsViewController

            loadStoredSettings()

            settingViewController.selectedRadius = selectedRadius
            settingViewController.selectedSensorTypes = selectedSensorTypes
            settingViewController.delegate = self
        case "SaveSettingsSegue":
            userDefaults.set(selectedRadius, forKey: Constants.KEY_RADIUS)

            for (key, value) in selectedSensorTypes {
                userDefaults.set(value, forKey: key)
            }
        default:
            return
        }
    }
}

// MARK: - SettingsViewControllerDelegate
extension SettingsContainerViewController: SettingsViewControllerDelegate {
    func didToggleSwitch(on: Bool, key: String) {
        selectedSensorTypes[key] = on
    }

    func didChangeSlider(value: Int) {
        selectedRadius = value
    }
}
