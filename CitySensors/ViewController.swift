//
//  ViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/8/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let parameters: Parameters = [
            "api_key": APIConfig.API_KEY,
        ]

        print("getting data...")
        ApiHandler.getLiveSensorData(with: parameters, onSuccess: { sensors in
            print("Here's what I got")
            print(sensors)
        }, onError: { error in
            print(error)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

