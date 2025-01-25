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

    var selectedCity: String? // 選択された都市を受け取るプロパティ
    var cityNameText: [String: String] = ["ベルリン": "Berlin", "アムステルダム": "Amsterdam", "ロンドン": "London", "東京": "Tokyo", "バンコク": "Bangkok", "シドニー": "Sydney", "メルボルン": "Melbourne", "ケープタウン": "Cape Town"]
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        
        // 選択された都市に基づいて CityNameLabel を設定
        if let selectedCity = selectedCity,
           let englishCityName = cityNameText[selectedCity] {
            CityNameLabel.text = englishCityName
        } else {
            CityNameLabel.text = "不明な都市"
        }
        
        title = CityNameLabel.text
        self.searchWeather()
        
        // 背景画像を設定
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "backgroundImage") // あなたの画像ファイル名に置き換え
        backgroundImageView.contentMode = .scaleAspectFill // 画像をアスペクト比を保って広げる
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 背景画像ビューを追加
        view.addSubview(backgroundImageView)
        
        // 制約を設定して Safe Area を無視し、画面全体に広げる
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

