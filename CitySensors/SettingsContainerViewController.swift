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

    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarStyle(UIStatusBarStyleContrast)

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
}
