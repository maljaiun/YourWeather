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

     func withGeolocationWeather(completion: @escaping () -> ()) {
        LocationWeatherManager.shared.getCurrentWeather(lat: lat!, lon: lon!, locale: lang!) { [weak self] newCurrentWeather in
            self?.currentWeatherObject = newCurrentWeather
            LocationWeatherManager.shared.getDailyWeather(lat: (self?.lat)!, lon: (self?.lon)!, locale: (self?.lang)!) { [weak self] dailyWeatherObject in
                self?.dailyWeatherObject = dailyWeatherObject
                completion()
            }
        }
    }
    
     func noGeolocationWeather(completion: @escaping () -> ()) {
         NoLocationWeatherManager.shared.getCurrentWeather(lang: lang!) { [weak self] newCurrentWeather in
            self?.currentWeatherObject = newCurrentWeather
             NoLocationWeatherManager.shared.getDailyWeather(lang: (self?.lang!)!) { [weak self] dailyWeatherObject in
                self?.dailyWeatherObject = dailyWeatherObject
                completion()
            }
        }
    }
    
    func dateFormater(date: TimeInterval, dateFormat: String) -> String {
        let dateText = Date(timeIntervalSince1970: date)
        let formater = DateFormatter()
        formater.timeZone = TimeZone(secondsFromGMT: self.currentWeatherObject?.timezone ?? 0)
        formater.dateFormat = dateFormat
        return formater.string(from: dateText)
    }
    
}

