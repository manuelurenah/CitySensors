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
    var waypointImage = UIImage()
    var todayImage = UIImage()
    var lastWeekImage = UIImage()
    var isWaypoint = true
    var lastWeekSensor: UrbanObservatorySensor? {
        didSet {
            lastWeekImage = lastWeekSensor!.buildLastWeekImage()
        }
    }

    init(location: CLLocation?, sensor: UrbanObservatorySensor, isWaypoint: Bool) {
        self.sensor = sensor
        self.isWaypoint = isWaypoint
        self.todayImage = sensor.buildBillboardImage()
        self.waypointImage = sensor.buildWaypointImage()

        super.init(location: location, image: isWaypoint ? self.waypointImage : self.todayImage)
    }

    init(location: CLLocation?, sensor: UrbanObservatorySensor, isWaypoint: Bool, lastWeekSensor: UrbanObservatorySensor) {
        self.sensor = sensor
        self.lastWeekSensor = lastWeekSensor
        self.isWaypoint = isWaypoint
        self.todayImage = sensor.buildBillboardImage()
        self.waypointImage = sensor.buildWaypointImage()
        self.lastWeekImage = lastWeekSensor.buildLastWeekImage()

        super.init(location: location, image: isWaypoint ? self.waypointImage : self.todayImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
