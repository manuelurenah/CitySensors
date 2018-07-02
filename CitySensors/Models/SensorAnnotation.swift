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
        switch sensorType {
        case "Air Quality":
            return UIColor(hex: 0x24A789)!
        case "Bee Hive":
            return UIColor(hex: 0xF46A2B)!
        case "Environmental":
            return UIColor(hex: 0x1B811E)!
        case "High Precision Air Monitor":
            return UIColor(hex: 0x22486B)!
        case "River Level":
        	return UIColor(hex: 0x182EF2)!
        case "Tidal Level":
            return UIColor(hex: 0x69CDB8)!
        case "Traffic":
            return UIColor(hex: 0x828282)!
        case "Weather":
            return UIColor(hex: 0x6A8121)!
        default:
            return .red
        }
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
