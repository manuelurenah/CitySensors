//
//  SensorNode.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/22/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import ARCL
import ARKit
import CoreLocation
import SceneKit

class SensorNode: LocationAnnotationNode {

    var sensor: Sensor?

    init(sensor: Sensor, location: CLLocation?, image: UIImage) {
        super.init(location: location, image: image)

        self.sensor = sensor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
