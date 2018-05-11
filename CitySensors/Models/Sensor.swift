//
//  Sensor.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation

enum SensorType: String, Codable {
    case airQuality
    case beeHive
    case environmental
    case highPrecisionAirMonitor
    case riverLevel
    case tidalLevel
    case traffic
    case weather
}

// MARK: - Sensor struct Model
public struct Sensor: Codable {
    let name: String
    let type: SensorType
    let active: Bool
    let source: String
    let longitude: Double
    let latitude: Double
    let variable: String
    let units: String
    let timestamp: Date
    let value: Double
}
