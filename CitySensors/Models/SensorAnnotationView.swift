//
//  SensorAnnotationView.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 6/27/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class SensorAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let sensorAnnotation = newValue as? SensorAnnotation else { return }
            image = UIImage(named: sensorAnnotation.sensorType)
        }
    }
}
