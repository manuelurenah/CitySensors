//
//  Constants.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation

enum APIConfig {
    static let API_KEY = "coea8x3xajteanx9suaifwbqbea0ixrtu4flkob9mfrcmpf4prllvztsnuz1i4bbkimtugj1ejjzck49bpu85vylhx"
    static let API_BASE_URL = "http://uoweb1.ncl.ac.uk/api/v1"
}

enum Constants {
    static let DEFAULT_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss"

    static let DEFAULT_RADIUS = 100
    static let DEFAULT_SENSOR_HEIGHT = 50.0
    static let DEFAULT_GEOFENCE_RADIUS = 20.0
    static let INITIAL_COORDINATES = [
        "latitude": 55.002352,
        "longitude": -1.7268829
    ]

    static let KEY_RADIUS = "userRadius"
}

enum UserSettingsKeys {
    static let AIR_QUALITY = "Air Quality"
    static let BEE_HIVE = "Bee Hive"
    static let ENVIRONMENTAL = "Environmental"
    static let HIGH_PRECISION_AIR_MONITOR = "High Precision Air Monitor"
    static let RIVER_LEVEL = "River Level"
    static let TIDAL_LEVEL = "Tidal Level"
    static let TRAFFIC = "Traffic"
    static let WEATHER = "Weather"

    static let INITIAL_SETUP = [
        AIR_QUALITY: true,
        BEE_HIVE: true,
        ENVIRONMENTAL: true,
        HIGH_PRECISION_AIR_MONITOR: true,
        RIVER_LEVEL: true,
        TIDAL_LEVEL: true,
        TRAFFIC: true,
        WEATHER: true,
    ]
}
