//
//  SceneLocationView+Extension.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 8/15/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import ARKit
import ARCL

extension SceneLocationView {
    func resetSession() {
        self.session.pause()

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        if self.orientToTrueNorth {
            configuration.worldAlignment = .gravityAndHeading
        } else {
            configuration.worldAlignment = .gravity
        }

        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
