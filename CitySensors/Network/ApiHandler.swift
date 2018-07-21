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

    private static func decodeSensors(sensorData: Data) -> [UrbanObservatorySensor] {
        var sensors = [UrbanObservatorySensor]()
        do {
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(
                positiveInfinity: "+Infinity",
                negativeInfinity: "-Infinity",
                nan: "NaN"
            )

            sensors = try decoder.decode([UrbanObservatorySensor].self, from: sensorData)
        } catch let error {
            print(error)
        }

        return sensors;
    }

    static func getLiveSensorData(with parameters: [String: Any], onSuccess: @escaping ([UrbanObservatorySensor])->(), onError: @escaping (Error)->()) {
        provider.rx.request(.getLiveSensorData(parameters: parameters)).subscribe { event in
            switch event {
            case let .success(response):
                let sensors = decodeSensors(sensorData: response.data)

                onSuccess(sensors)
            case let .error(error):
                onError(error)
            }
        }.disposed(by: disposeBag)
    }

    static func getSensors(with parameters: [String: Any], onSuccess: @escaping ([UrbanObservatorySensor])->(), onError: @escaping (Error)->()) {
        provider.rx.request(.getSensors(parameters: parameters)).subscribe { event in
            switch event {
            case let .success(response):
                let sensors = decodeSensors(sensorData: response.data)

                onSuccess(sensors)
            case let .error(error):
                onError(error)
            }
        }.disposed(by: disposeBag)
    }
}
