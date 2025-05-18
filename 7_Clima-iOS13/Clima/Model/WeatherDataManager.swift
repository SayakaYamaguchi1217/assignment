//
//  WeatherDataManager.swift
//  Clima
//
//  Created by Daegeon Choi on 2020/04/15.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

//MARK: Delegate protocol
protocol WeatherManagerDelegate {
    func updateWeather(weatherModel: WeatherModel)
    func failedWithError(error: Error)
}

//MARK: DataManager struct
struct WeatherDataManager {
    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=4e415e4ab2aaed09e04d8419beedee19&units=metric"
    var delegate: WeatherManagerDelegate?
    let client = APIClient()
    
    func fetchWeather(_ city: String) {
        let completeURL = "\(baseURL)&q=\(city)"
        requestWeather(url: completeURL)
    }
    
    func fetchWeather(_ latitude: Double, _ longitude: Double) {
        let completeURL = "\(baseURL)&lat=\(latitude)&lon=\(longitude)"
        requestWeather(url: completeURL)
    }
    
    private func requestWeather(url: String) {
            client.request(url: url, responseType: WeatherResponse.self) { result in
                switch result {
                case .success(let response):
                    let weatherModel = WeatherModel(
                        cityName: response.name,
                        conditionId: response.weather.first?.id ?? 0,
                        temperature: response.main.temp
                    )
                    delegate?.updateWeather(weatherModel: weatherModel)
                case .failure(let error):
                    delegate?.failedWithError(error: error)
                }
            }
        }
    }
