//
//  BillboardView.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/30/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class BillboardView: UIView {

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readingsLabel: UILabel!
    @IBOutlet weak var billboardContainerView: UIView!
    @IBOutlet weak var latestReadingLabel: UILabel!

    var sensorType: String! {
        didSet {
            switch sensorType {
            case "Air Quality":
                iconBackground = UIColor(hex: 0x24A789)!
            case "Bee Hive":
                iconBackground = UIColor(hex: 0xF46A2B)!
            case "Environmental":
                iconBackground = UIColor(hex: 0x1B811E)!
            case "High Precision Air Monitor":
                iconBackground = UIColor(hex: 0x22486B)!
            case "River Level":
                iconBackground = UIColor(hex: 0x182EF2)!
            case "Tidal Level":
                iconBackground = UIColor(hex: 0x69CDB8)!
            case "Traffic":
                iconBackground = UIColor(hex: 0x828282)!
            case "Weather":
                iconBackground = UIColor(hex: 0x6A8121)!
            default:
                iconBackground = .red
            }
        }
    }

    var iconBackground: UIColor! {
        didSet {
            titleContainerView.backgroundColor = iconBackground
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        billboardContainerView.cornerRadius = billboardContainerView.bounds.height / 20
    }
}
