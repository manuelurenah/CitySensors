//
//  ApiHandler.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import SwiftyJSON

class ApiHandler {
    static let provider = MoyaProvider<SensorService>()

    static func getLiveSensorData(with parameters: Parameters, onSuccess: @escaping ([Sensor])->(), onError: @escaping (Error)->()) {
        provider.rx.request(.getLiveSensorData(parameters: parameters)).subscribe { event in
            switch event {
            case let .success(response):
                do {
                    let results = try JSON(data: response.data) as! [Sensor]

                    onSuccess(results)
                } catch let error {
                    onError(error)
                }
            case let .error(error):
                onError(error)
            }
        }
    }
}
