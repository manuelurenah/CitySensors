//
//  MKMapView+Extension.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 6/27/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func centerMap(on location: CLLocation, delta: Double, animated: Bool = false) {
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)

        self.region = region
    }
}
