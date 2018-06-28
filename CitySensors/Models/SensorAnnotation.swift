//
//  SensorAnnotation.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 6/27/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class SensorAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let sensorName: String
    let sensorType: String
    let image: UIImage

    var subtitle: String? {
        return sensorName
    }

    var markerTintColor: UIColor {
        return UIColor(averageColorFrom: image)
    }

    init(title: String, coordinate: CLLocationCoordinate2D, sensorName: String, sensorType: String, image: UIImage) {
        self.title = title
        self.coordinate = coordinate
        self.sensorName = sensorName
        self.sensorType = sensorType
        self.image = image

        super.init()
    }
}
