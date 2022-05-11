//
//  WeatherModel.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 15.03.2022.
//

import Foundation
import CoreLocation

class WeatherModel {
    
    var lang = Locale.current.languageCode
    var lat: Double?
    var lon: Double?
    var currentWeatherObject: CurrentWeatherObject?
    var dailyWeatherObject: DailyWeatherObject?
    
    private let group = DispatchGroup()
    
    func withGeolocationWeather(completion: @escaping () -> ()) {
        
        group.enter()
        LocationWeatherManager.shared.getCurrentWeather(lat: lat!, lon: lon!, locale: lang!) { [weak self] newCurrentWeather in
            self?.currentWeatherObject = newCurrentWeather
            self?.group.leave()
        }
        
        group.enter()
        LocationWeatherManager.shared.getDailyWeather(lat: lat!, lon: lon!, locale: lang!) { [weak self] dailyWeatherObject in
            self?.dailyWeatherObject = dailyWeatherObject
            self?.group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func noGeolocationWeather(completion: @escaping () -> ()) {
 
        group.enter()
        NoLocationWeatherManager.shared.getCurrentWeather(lang: lang!) { [weak self] newCurrentWeather in
            self?.currentWeatherObject = newCurrentWeather
            self?.group.leave()
        }
        
        group.enter()
        NoLocationWeatherManager.shared.getDailyWeather(lang: lang!) { [weak self] dailyWeatherObject in
            self?.dailyWeatherObject = dailyWeatherObject
            self?.group.leave()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
   
}

