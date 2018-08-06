//
//  Sensor.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Sensor struct Model
class UrbanObservatorySensor: Codable {
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

        let data: [String: Double]
        let meta: Meta
    }

    let latestReading: String
    let geometry: Geometry
    let active: String
    let type: String
    let source: Source
    let data: [String: Value]
    let baseHeight: Double
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

    required init(from decoder: Decoder) throws {
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

        if let baseHeightValue = try? container.decode(String.self, forKey: .baseHeight) {
            baseHeight = Double(baseHeightValue)!
        } else {
            baseHeight = try container.decode(Double.self, forKey: .baseHeight)
        }

        if let sensorHeightValue = try? container.decode(Float.self, forKey: .sensorHeight) {
            sensorHeight = String(sensorHeightValue)
        } else {
            sensorHeight = try container.decode(String.self, forKey: .sensorHeight)
        }

        name = try container.decode(String.self, forKey: .name)
    }

    func getReadings(values: [String: Value]? = nil) -> String {
        let source = values ?? data
        return source.reduce("") { (result, entry) in
            guard let currentReading = entry.value.data.first?.value else { return "" }
            let formattedReading = String(format: "%.2f", currentReading)

            return result + "\(entry.key): \(formattedReading) \(entry.value.meta.units)\n"
        }
    }

    func getAverageReadings() -> [String: Value] {
        var averageReadings = [String: Value]()

        data.forEach { item in
            let (environmentVariable, value) = item
            let valuesCount = Double(value.data.count)
            let averageValue = value.data.reduce(0.0) { (result, entry) in result + entry.value } / valuesCount
            let newData = [environmentVariable: averageValue]
            let newValue = Value(data: newData, meta: value.meta)

            averageReadings[environmentVariable] = newValue
        }

        return averageReadings
    }

    func buildBillboardImage() -> UIImage {
        let billboardView: BillboardView = BillboardView.fromNib()

        billboardView.titleLabel.text = source.webDisplayName
        billboardView.sensorType = type
        billboardView.iconImageView.image = UIImage(named: type)
        billboardView.readingsLabel.text = getReadings()
        billboardView.latestReadingLabel.text = Date(dateString: latestReading, format: Constants.DEFAULT_DATE_FORMAT).timeAgoSinceNow

        return billboardView.takeSnapshot()
    }

    func buildWaypointImage() -> UIImage {
        let waypointView: WaypointView = WaypointView.fromNib()

        waypointView.sensorType = type
        waypointView.iconImageView.image = UIImage(named: type)

        return waypointView.takeSnapshot()
    }

    func buildLastWeekImage() -> UIImage {
        let averageReading = getAverageReadings()
        let billboardView: BillboardView = BillboardView.fromNib()

        billboardView.titleLabel.text = source.webDisplayName
        billboardView.sensorType = type
        billboardView.iconImageView.image = UIImage(named: type)
        billboardView.readingsLabel.text = getReadings(values: averageReading)
        billboardView.latestReadingLabel.text = "Last Week"

        return billboardView.takeSnapshot()
    }
}
