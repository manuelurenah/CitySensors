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
    func setCenter(on location: CLLocation, with regionRadius: Double, animated: Bool = false) {
        let regionDistance = CLLocationDistance(regionRadius)
        let mapRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionDistance, regionDistance)

        self.setRegion(mapRegion, animated: animated)
    }
}
