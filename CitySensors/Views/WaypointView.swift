//
//  WaypointView.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 6/28/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import UIKit

class WaypointView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pinImageView: UIImageView!

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
                iconBackground = UIColor.red
            }
        }
    }

    var iconBackground: UIColor! {
        didSet {
            pinImageView.tintColor = iconBackground
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.cornerRadius = self.bounds.height / 2
        pinImageView.image = pinImageView.image?.withRenderingMode(.alwaysTemplate)
    }
}
