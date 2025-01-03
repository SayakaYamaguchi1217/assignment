//
//  ThirdViewController.swift
//  Clima
//
//  Created by p10p093 on 2024/12/31.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class ThirdViewController: UIViewController {
    // 親から受け取る変数
        var getName: String = ""
    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var CityName: UILabel!
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         locationManager.delegate = self
//         weatherManager.delegate = self
        
        // Labelへ格納
        self.CityName.text = getName
        title = getName
    }

}

//MARK:- TextField extension
extension ThirdViewController: UITextFieldDelegate {    
    func searchWeather(){
        if let cityName = self.CityName.text{
            weatherManager.fetchWeather(cityName)
        }
    }
}

//MARK:- View update extension
extension ThirdViewController: WeatherManagerDelegate {
    
    func updateWeather(weatherModel: WeatherModel){
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            CityName.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            
        }
    }
    
    func failedWithError(error: Error){
        print(error)
    }
}

// MARK:- CLLocation
extension ThirdViewController: CLLocationManagerDelegate {
    
    @IBAction func locationButtonClicked(_ sender: UIButton) {
        // Get permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(lat, lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
