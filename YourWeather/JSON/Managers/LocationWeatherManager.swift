//
//  WeatherManager.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 19.02.2022.
//

import Foundation

class LocationWeatherManager {
    
    static let shared = LocationWeatherManager()
    let key = "1c2ba745810db56a9f945361a2520a0a"
    
    private init() {}
 
    func getCurrentWeather(lat:Double,lon:Double,locale: String,completion: @escaping (CurrentWeatherObject?) -> ()) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=\(locale)&units=metric&appid=\(key)") else { return }
        let request = URLRequest(url: url)
        let newCurrentWeather = CurrentWeatherObject()
        
        let task = URLSession.shared
            .dataTask(with: request) { data, response, error in
                if error == nil,
                   let data = data {
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
                            if let timezone = json["timezone"] as? Int,
                               let dt = json["dt"] as? TimeInterval,
                               let name = json["name"] as? String {
                                newCurrentWeather.timezone = timezone
                                newCurrentWeather.dt = dt
                                newCurrentWeather.name = name
                            }
                            let newWeather = NewWeather()
                            guard let weather = json["weather"] as? [[String:Any]] else { return }
                            if let id = weather.first?["id"] as? Double,
                               let description = weather.first?["description"] as? String,
                               let icon = weather.first?["icon"] as? String {
                                newWeather.id = id
                                newWeather.description = description
                                newWeather.icon = icon
                                newCurrentWeather.weather = newWeather
                            }
                            
                            guard let main = json["main"] as? [String:Any] else { return }
                            if let temp = main["temp"] as? Double,
                               let feels_like = main["feels_like"] as? Double,
                               let temp_min = main["temp_min"] as? Double,
                               let temp_max = main["temp_max"] as? Double,
                               let hunidity = main["humidity"] as? Double,
                               let pressure = main["pressure"] as? Double {
                                newCurrentWeather.temp = temp
                                newCurrentWeather.feels_like = feels_like
                                newCurrentWeather.temp_max = temp_max
                                newCurrentWeather.temp_min = temp_min
                                newCurrentWeather.humidity = hunidity
                                newCurrentWeather.pressurre = pressure
                            }
                            
                            guard let wind = json["wind"] as? [String: Any] else { return }
                            if let speed = wind["speed"] as? Double{
                                newCurrentWeather.speed = speed
                            }
                            guard let sys = json["sys"] as? [String:Any] else { return }
                            if let country = sys["country"] as? String {
                                newCurrentWeather.country = country
                            }
                            DispatchQueue.main.async {
                                completion(newCurrentWeather)
                            }
                      
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        task.resume()
        
    }
    
    func getDailyWeather(lat:Double,lon:Double,locale: String, completion: @escaping (DailyWeatherObject?) -> ()) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&lang=\(locale)&exclude=minutely&units=metric&appid=\(key)") else { return }
        let request = URLRequest(url: url)
        let dailyWeatherObject = DailyWeatherObject()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil,
               let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] {
                            
                        let hourlyWeather = HourlyWeather()
                        guard let hourly = json["hourly"] as? [[String:Any]] else { return }
                        for hourly in hourly{
                            if let dt = hourly["dt"] as? TimeInterval,
                               let temp = hourly["temp"] as? Double {
                                hourlyWeather.dt.append(dt)
                                hourlyWeather.temp.append(temp)
                            }
                            guard let weather = hourly["weather"] as? [[String:Any]] else { return }
                            if let icon = weather.first?["icon"] as? String {
                                hourlyWeather.icon.append(icon)
                            }
                        }
                        dailyWeatherObject.hourly = hourlyWeather
                        
                        guard let daily = json["daily"] as? [[String: Any]] else { return }
                        for daily in daily {
                            if let dt = daily["dt"] as? TimeInterval {
                                dailyWeatherObject.dt.append(dt)
                            }
                            guard let temp = daily["temp"] as? [String:Any] else { return }
                            if let min = temp["min"] as? Double,
                               let max = temp["max"] as? Double{
                                dailyWeatherObject.min.append(min)
                                dailyWeatherObject.max.append(max)
                            }
                            guard let weather = daily["weather"] as? [[String: Any]] else { return }
                            if let icon = weather.first?["icon"] as? String {
                                dailyWeatherObject.icon.append(icon)
                            }
                        }
                        DispatchQueue.main.async {
                            completion(dailyWeatherObject)
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}





