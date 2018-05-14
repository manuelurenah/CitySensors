//
//  Sensor.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation

// MARK: - Sensor struct Model
struct Sensor: Codable {
    struct Geometry: Codable {
        let coordinates: [Double]
        let type: String
    }

    struct Source: Codable {
        let fancyName: String
        let document: String?
        let thirdParty: Bool?
        let dbName: String
        let webDisplayName: String

        private enum CodingKeys: String, CodingKey {
            case fancyName = "fancy_name"
            case document
            case thirdParty = "third_party"
            case dbName = "db_name"
            case webDisplayName = "web_display_name"
        }
    }

    struct Value: Codable {
        struct Meta: Codable {
            let units: String
            let name: String
            let theme: String
        }

        let data: [String:Float]
        let meta: Meta
    }

    let latestReading: String
    let geometry: Geometry
    let active: String
    let type: String
    let source: Source
    let data: [String:Value]
    let baseHeight: String
    let sensorHeight: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case latestReading = "latest"
        case geometry = "geom"
        case active
        case type
        case source
        case data
        case baseHeight = "base_height"
        case sensorHeight = "sensor_height"
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        latestReading = try container.decode(String.self, forKey: .latestReading)
        geometry = try container.decode(Geometry.self, forKey: .geometry)

        if let activeValue = try? container.decode(Bool.self, forKey: .active) {
            active = String(activeValue)
        } else {
            active = try container.decode(String.self, forKey: .active)
        }

        type = try container.decode(String.self, forKey: .type)
        source = try container.decode(Source.self, forKey: .source)
        data = try container.decode([String:Value].self, forKey: .data)

        if let baseHeightValue = try? container.decode(Float.self, forKey: .baseHeight) {
            baseHeight = String(baseHeightValue)
        } else {
            baseHeight = try container.decode(String.self, forKey: .baseHeight)
        }

        if let sensorHeightValue = try? container.decode(Float.self, forKey: .sensorHeight) {
            sensorHeight = String(sensorHeightValue)
        } else {
            sensorHeight = try container.decode(String.self, forKey: .sensorHeight)
        }

        name = try container.decode(String.self, forKey: .name)
    }
}
