//
//  SpriteKitViewController.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/16/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit

class SpriteKitViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupSceneView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func setupSceneView() {
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
        sceneView.delegate = self
    }

    func addWaypoint() {
        let skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = UIColor.clear

        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
        rectangle.fillColor = #colorLiteral(red: 0.807843148708344, green: 0.0274509806185961, blue: 0.333333343267441, alpha: 1.0)
        rectangle.strokeColor = #colorLiteral(red: 0.439215689897537, green: 0.0117647061124444, blue: 0.192156866192818, alpha: 1.0)
        rectangle.lineWidth = 5
        rectangle.alpha = 0.4

        let labelNode = SKLabelNode(text: "Hello World")
        labelNode.fontSize = 20
        labelNode.fontName = "San Fransisco"
        labelNode.position = CGPoint(x:100,y:100)
        skScene.addChild(rectangle)
        skScene.addChild(labelNode)

        let plane = SCNPlane(width: 20, height: 20)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        let node = SCNNode(geometry: plane)
    }
}

extension SpriteKitViewController: ARSKViewDelegate {
}
