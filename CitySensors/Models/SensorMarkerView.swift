//
//  SensorAnnotationView.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 6/27/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

class SensorMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let sensorAnnotation = newValue as? SensorAnnotation else { return }

            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            markerTintColor = sensorAnnotation.markerTintColor
            glyphImage = UIImage(named: sensorAnnotation.sensorType)
        }
    }
}
