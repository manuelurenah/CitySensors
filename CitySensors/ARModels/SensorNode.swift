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

    init(location: CLLocation?, sensor: UrbanObservatorySensor, asWaypoint: Bool) {
        self.sensor = sensor

        var nodeImage = UIImage()

        if asWaypoint {
            let waypointView: WaypointView = WaypointView.fromNib()

            waypointView.sensorType = sensor.type
            waypointView.iconImageView.image = UIImage(named: sensor.type)

            nodeImage = waypointView.takeSnapshot()
        } else {
            let billboardView: BillboardView = BillboardView.fromNib()

            billboardView.titleLabel.text = sensor.source.webDisplayName
            billboardView.sensorType = sensor.type
            billboardView.iconImageView.image = UIImage(named: sensor.type)
            billboardView.readingsLabel.text = sensor.getReadings()
            billboardView.latestReadingLabel.text = Date(dateString: sensor.latestReading, format: Constants.DEFAULT_DATE_FORMAT).timeAgoSinceNow

            nodeImage = billboardView.takeSnapshot()
        }

        super.init(location: location, image: nodeImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
