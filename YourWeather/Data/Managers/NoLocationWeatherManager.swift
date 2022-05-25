//
//  StartWeatherManager.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 23.02.2022.
//

import Foundation

class NoLocationWeatherManager {
    
    static let shared = NoLocationWeatherManager()
    private let key = "1c2ba745810db56a9f945361a2520a0a"
    
    private init() {}
 
    func getCurrentWeather(lang: String, completion: @escaping (Result<CurrentWeather,NetworkError>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=53.9024716&lon=27.5618225&lang=\(lang)&units=metric&appid=\(key)") else {
            completion(.failure(.serverError))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.serverError))
                return
            }
            do {
                let weather = try JSONDecoder().decode(CurrentWeather.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
    func getDailyWeather(lang: String, completion: @escaping (Result<DailyWeather,NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=53.9024716&lon=27.5618225&lang=\(lang)&exclude=minutely&units=metric&appid=\(key)") else {
            completion(.failure(.serverError))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.serverError))
                return
            }
            do {
                let weather = try JSONDecoder().decode(DailyWeather.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
    
}
