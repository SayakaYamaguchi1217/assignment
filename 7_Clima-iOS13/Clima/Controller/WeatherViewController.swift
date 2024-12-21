//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    @IBAction func DadJokeButton(_ sender: Any) {
        fetchDadJoke()
    }
    
    @IBOutlet weak var DadJokeLabel: UILabel!
    
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        weatherManager.delegate = self
        searchField.delegate = self
        
        // 初期設定
        DadJokeLabel.text = "Tap the button for a Dad Joke!"
    }
    
    // APIから親父ギャグを取得するメソッド
        func fetchDadJoke() {
            let urlString = "https://icanhazdadjoke.com/"
            guard let url = URL(string: urlString) else { return }

            // URLRequestの作成
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            // URLSessionでデータを取得
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error fetching joke: \(error)")
                    return
                }

                guard let data = data else { return }
                do {
                    // JSONのデコード
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let joke = json["joke"] as? String {
                        DispatchQueue.main.async {
                            self.DadJokeLabel.text = joke // 取得したギャグをUILabelに表示
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        }
}
 
//MARK:- TextField extension
extension WeatherViewController: UITextFieldDelegate {
    
        @IBAction func searchBtnClicked(_ sender: UIButton) {
            searchField.endEditing(true)    //dismiss keyboard
            print(searchField.text!)
            
            searchWeather()
        }
    
    func searchWeather(){
        if let cityName = searchField.text{
            weatherManager.fetchWeather(cityName)
        }
    }
        
        // when keyboard return clicked
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            searchField.endEditing(true)    //dismiss keyboard
            print(searchField.text!)
            
            searchWeather()
            return true
        }
        
        // when textfield deselected
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            // by using "textField" (not "searchField") this applied to any textField in this Controller(cuz of delegate = self)
            if textField.text != "" {
                return true
            }else{
                textField.placeholder = "Type something here"
                return false            // check if city name is valid
            }
        }
        
        // when textfield stop editing (keyboard dismissed)
        func textFieldDidEndEditing(_ textField: UITextField) {
    //        searchField.text = ""   // clear textField
        }
}

//MARK:- View update extension
extension WeatherViewController: WeatherManagerDelegate {
    
    func updateWeather(weatherModel: WeatherModel){
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            cityLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            
            switch searchField.text {
            case "Tokyo":
                self.backgroundImageView.image = UIImage(named: "starbacks")
                
            case "Kyoto":
                self.backgroundImageView.image = UIImage(named: "pikachu")
                
            default:
                self.backgroundImageView.image = UIImage(named: "background")
            }
        }
    }
    
    func failedWithError(error: Error){
        print(error)
    }
}

// MARK:- CLLocation
extension WeatherViewController: CLLocationManagerDelegate {
    
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
