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

    var sensor: UrbanObservatorySensor
    var lastDaySensor: UrbanObservatorySensor
    var waypointImage = UIImage()
    var todayImage = UIImage()
    var lastDayImage = UIImage()
    var isWaypoint = true

    init(location: CLLocation?, sensor: UrbanObservatorySensor, lastDaySensor: UrbanObservatorySensor, isWaypoint: Bool) {
        self.sensor = sensor
        self.lastDaySensor = lastDaySensor
        self.isWaypoint = isWaypoint
        self.todayImage = sensor.buildBillboardImage()
        self.waypointImage = sensor.buildWaypointImage()
        self.lastDayImage = lastDaySensor.buildLastDayImage()

        super.init(location: location, image: isWaypoint ? self.waypointImage : self.todayImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
