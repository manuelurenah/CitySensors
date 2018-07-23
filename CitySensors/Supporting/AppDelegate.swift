//
//  AppDelegate.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import CoreLocation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        return true
    }

    func handle(event region: CLRegion) {
        if UIApplication.shared.applicationState == .active {
            window?.rootViewController?.showAlert(title: "Triggered", message: "\(region.identifier)")
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handle(event: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handle(event: region)
        }
    }
}

