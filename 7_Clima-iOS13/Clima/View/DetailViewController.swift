//
//  DetailViewController.swift
//  Clima
//
//  Created by p10p093 on 2025/01/13.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var CityNameLabel: UILabel!
    var cityNameText: String?
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        
        if let cityName = cityNameText{
            if cityName == "ベルリン" {
                CityNameLabel.text = "Berlin"
            } else if cityName == "アムステルダム" {
                CityNameLabel.text = "Amsterdam"
            } else if cityName == "ロンドン" {
                CityNameLabel.text = "London"
            } else if cityName == "東京" {
                CityNameLabel.text = "Tokyo"
            } else if cityName == "バンコク" {
                CityNameLabel.text = "Bangkok"
            } else if cityName == "シドニー" {
                CityNameLabel.text = "Sydney"
            } else if cityName == "メルボルン" {
                CityNameLabel.text = "Melbourne"
            } else if cityName == "ケープタウン" {
                CityNameLabel.text = "Cape Town"
            }
            
        }
        
        title = CityNameLabel.text
        self.searchWeather()
    }
    
    func searchWeather(){
        if let cityName = CityNameLabel.text{
            weatherManager.fetchWeather(cityName)
        }
    }
    
}

//MARK:- View update extension
extension DetailViewController: WeatherManagerDelegate {
    
    func updateWeather(weatherModel: WeatherModel){
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            CityNameLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
        }
    }
    
    func failedWithError(error: Error){
        print(error)
    }
}

