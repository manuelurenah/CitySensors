//
//  ApiHandler.swift
//  CitySensors
//
//  Created by Manuel Emilio Ureña on 5/10/18.
//  Copyright © 2018 Newcastle University. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class ApiHandler {
    static let provider = MoyaProvider<SensorService>()
    static let disposeBag = DisposeBag()

    static func getLiveSensorData(with parameters: [String : Any], onSuccess: @escaping ([Sensor])->(), onError: @escaping (Error)->()) {
        provider.rx.request(.getLiveSensorData(parameters: parameters)).subscribe { event in
            switch event {
            case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
                        positiveInfinity: "+Infinity",
                        negativeInfinity: "-Infinity",
                        nan: "NaN"
                    )

                    let sensors = try decoder.decode([Sensor].self, from: response.data)

                    onSuccess(sensors)
                } catch let error {
                    onError(error)
                }
            case let .error(error):
                onError(error)
            }
        }.disposed(by: disposeBag)
    }
}
