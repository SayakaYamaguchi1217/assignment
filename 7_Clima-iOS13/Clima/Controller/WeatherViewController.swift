//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAnalytics

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    
    @IBAction func DadJokeButton(_ sender: Any) {
        fetchDadJoke()
        // イベント送信
        Analytics.logEvent("tap_dad_joke", parameters: [
            "screenName": "WeatherViewController"
        ])
    }
    
    @IBOutlet weak var DadJokeLabel: UILabel!
    
    @IBAction func RandomDogsButton(_ sender: Any) {
        fetchDogImage()
    }
    
    @IBOutlet weak var RandomDogsImage: UIImageView!
    @IBAction func Button(_ sender: UIButton) {
        let vc = FavoriteViewController()
        navigationController?.pushViewController(vc, animated: true)
        
        
        // イベント送信
        Analytics.logEvent("tap_favorite_list", parameters: [
            "screenName": "FavoriteViewController",
        ])
    }
    
    @IBAction func city(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC =  storyboard.instantiateViewController(withIdentifier: "modal")
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    //MARK: Properties
    var weatherManager = WeatherDataManager()
    let locationManager = CLLocationManager()
    let client = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        weatherManager.delegate = self
        searchField.delegate = self
        
        // 初期設定
        DadJokeLabel.text = "Tap the button for a Dad Joke!"
        
        // ディープリンク通知を監視
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigateToFavorite), name: NSNotification.Name("navigateToFavorite"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigateToSearch(_:)), name: NSNotification.Name("navigateToSearch"), object: nil)
        
    }
    
    // お気に入り画面に遷移するハンドラー
    @objc func handleNavigateToFavorite() {
        print("✅ navigateToFavorite を受信しました")
        
        let vc = FavoriteViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 指定都市の天気を検索するハンドラー
    @objc func handleNavigateToSearch(_ notification: Notification) {
        guard let city = notification.object as? String else {
            print("❌ city 文字列が取得できませんでした")
            return
        }
        print("✅ navigateToSearch を受信: city = \(city)")
        
        // 🔽 ナビゲーションコントローラーで最初の画面に戻る
        navigationController?.popToRootViewController(animated: true)
        
        // 🔽 少し待ってから検索（戻るのに時間がかかるので）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.searchField.text = city
            self.searchWeather()
        }
    }
    
    // APIから親父ギャグを取得するメソッド
    func fetchDadJoke() {
        client.request(
            url: "https://icanhazdadjoke.com/",
            headers: ["Accept": "application/json"],
            responseType: DadJokeResponse.self
        ) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.DadJokeLabel.text = response.joke // 取得したジョークをラベルに表示
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // APIから犬画像を取得するメソッド
    func fetchDogImage() {
        client.request(
            url: "https://dog.ceo/api/breeds/image/random",
            responseType: DogImageResponse.self
        ) { result in
            switch result {
            case .success(let response):
                // URLから画像をダウンロードして表示
                if let imageUrl = URL(string: response.message) {
                    self.loadImage(from: imageUrl)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func loadImage(from url: URL) {
        // 画像データを取得
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Error decoding image data")
                return
            }
            
            // メインスレッドでUIImageViewを更新
            DispatchQueue.main.async {
                print("Image loaded successfully")
                self.RandomDogsImage.image = image
            }
        }
        
        task.resume()
    }
}

//MARK:- TextField extension
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchBtnClicked(_ sender: UIButton) {
        searchField.endEditing(true)    //dismiss keyboard
        print(searchField.text!)
        
        searchWeather()
    }
    
    func searchWeather() {
        if let cityName = searchField.text {
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
        var cityName = "unknown"
        
        // DispatchQueue.main.sync {}とは、「メインスレッドでこの処理を今すぐやって！終わるまで他の処理は全部ストップ！」という意味。
        // そのため、重い処理・API通信・ログ送信などはメインスレッドでやらないほうがいい。アプリが一瞬固まったり、最悪クラッシュしたりする可能性がある。
        // メインスレッドで UIアクセス & 値の取得
        DispatchQueue.main.sync {
            temperatureLabel.text = weatherModel.temperatureString
            cityLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
            
            // searchField.text に値が入っていたらそれを使う。もし nil だったら "unknown" を代わりに使う。
            cityName = searchField.text ?? "unknown"
            
            switch searchField.text {
            case "Tokyo":
                self.backgroundImageView.image = UIImage(named: "starbacks")
                
            case "Kyoto":
                self.backgroundImageView.image = UIImage(named: "pikachu")
                
            default:
                self.backgroundImageView.image = UIImage(named: "background")
            }
        }
        
        // メインスレッド外でログ処理
        Analytics.logEvent("search_weather", parameters: [
            "cityName": cityName,
            "screenName": "WeatherViewController"
        ])
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
