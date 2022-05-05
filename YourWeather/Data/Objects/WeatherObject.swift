//
//  WeatherObject.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 19.02.2022.
//

import Foundation

//current weather
class CurrentWeatherObject: Codable {
    var timezone: Int = 0
    var weather: NewWeather?
    var temp: Double = 0
    var feels_like: Double = 0
    var temp_min: Double = 0
    var temp_max: Double = 0
    var pressurre: Double = 0
    var humidity: Double = 0
    var speed: Double = 0
    var dt: TimeInterval = 0
    var name: String = ""
    var country: String = ""
    var lat: Double = 0
    var lon: Double = 0
    
}
class NewWeather: Codable {
    var id: Double = 0
    var description: String = ""
    var icon: String = ""
}

//daily weather
class DailyWeatherObject: Codable {
    var hourly: HourlyWeather?
    var min: [Double] = []
    var max: [Double] = []
    var dt: [TimeInterval] = []
    var icon: [String] = []
    var lat: Double = 0
    var lon: Double = 0
    
}

class HourlyWeather: Codable {
    var temp: [Double] = []
    var icon: [String] = []
    var dt: [TimeInterval] = []
}


