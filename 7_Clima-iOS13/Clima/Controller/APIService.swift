//
//  APIService.swift
//  Clima
//
//  Created by p10p093 on 2025/01/26.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class APIClient {
    func request<T: Decodable>(
        url: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // URLの生成
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        // パラメータがある場合はJSONエンコード
        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // URLSessionでリクエストを実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0)))
                return
            }
            
            // レスポンスをデコード
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct DadJokeResponse: Decodable {
    let id: String
    let joke: String
    let status: Int
}

struct DogImageResponse: Decodable {
    let message: String
    let status: String
}

struct WeatherResponse: Decodable {
    let name: String
    let weather: [WeatherCondition]
    let main: WeatherMain
    
    struct WeatherCondition: Decodable {
        let id: Int
    }
    
    struct WeatherMain: Decodable {
        let temp: Double
    }
}
