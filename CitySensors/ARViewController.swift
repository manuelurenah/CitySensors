//
//  ARViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/16/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!

    var sensor: Sensor!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLighting()
        addSphere(0.05)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpSceneView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        sceneView.session.run(configuration)

        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    func addSphere(_ radius: CGFloat) {
        let sphereGeometry = SCNSphere(radius: radius)
        let titleGeometry = SCNText(string: sensor.type, extrusionDepth: 0.2)
        titleGeometry.font = UIFont(name: "Arial", size: 2)

        sphereGeometry.materials.first?.diffuse.contents = UIColor.green

        let sphereNode = SCNNode(geometry: sphereGeometry)
        let titleNode = SCNNode(geometry: titleGeometry)

        sphereNode.position = SCNVector3(0, 0, -0.2)
        titleNode.center()
        titleNode.position = SCNVector3(0, 0.2, -0.2)
        titleNode.scale = SCNVector3(0.05, 0.05, 0.05)

        sceneView.scene.rootNode.addChildNode(sphereNode)
        sceneView.scene.rootNode.addChildNode(titleNode)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension SCNNode {
    func center() {
        let (min, max) = self.boundingBox

        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        self.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
}
