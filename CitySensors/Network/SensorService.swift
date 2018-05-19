//
//  SensorService.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import Moya

enum SensorService {
    case getSensors(parameters: [String : Any])
    case getLiveSensorData(parameters: [String : Any])
}

extension SensorService: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIConfig.API_BASE_URL) else { fatalError("baseURL could not be configured") }
        return url
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String : String]? {
        switch self {
        case .getSensors, .getLiveSensorData:
            return ["Content-Type": "application/json"]
        }
    }

    var path: String {
        switch self {
        case .getSensors:
            return "/sensors.json"
        case .getLiveSensorData:
            return "/sensors/live.json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSensors, .getLiveSensorData:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getSensors(let parameters),
             .getLiveSensorData(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
