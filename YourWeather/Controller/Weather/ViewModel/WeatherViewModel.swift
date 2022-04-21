//
//  WeatherViewModel.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 02.04.2022.
//

import Foundation
import UIKit
import CoreLocation

class WeatherViewModel: NSObject {
    
    //MARK: - vars/lets
    var navigationBarTitle = Bindable<String?>(nil)
    var currentPressure = Bindable<String?>(nil)
    var currentHumidity = Bindable<String?>(nil)
    var currentDescription =  Bindable<String?>(nil)
    var currentTemperature = Bindable<String?>(nil)
    var currentFeelingWeather = Bindable<String?>(nil)
    var currentImageWeather = Bindable<UIImage?>(nil)
    var currentMinWeather = Bindable<String?>(nil)
    var currentMaxWeather = Bindable<String?>(nil)
    var currentWindSpeed = Bindable<String?>(nil)
    var currentTime = Bindable<String?>(nil)
    var backgroundImageView = Bindable<UIImage?>(nil)
    var currentWeatherObject = Bindable<CurrentWeatherObject?>(nil)
    var dailyCollectionView = Bindable<DailyWeatherObject?>(nil)
    
    private let locationManager = CLLocationManager()
    var weather = WeatherModel()
    var reloadTableView: (()->())?
    var numberOfDailyCells: Int {
        return weather.dailyWeatherObject?.icon.count ?? 8
    }
    
    var numberOfHourlyCells: Int {
        return weather.dailyWeatherObject?.hourly?.temp.count ?? 24
    }
    
    
    //MARK: - flow func
    func addWeatherSettings() {
        guard let currentWeather = self.weather.currentWeatherObject else { return }
        self.navigationBarTitle.value = currentWeather.name
        self.currentTime.value = weather.dateFormater(date: currentWeather.dt, dateFormat: "HH:mm E")
        self.currentTemperature.value = "\(currentWeather.temp.doubleToString())°"
        self.currentFeelingWeather.value = "\(currentWeather.feels_like.doubleToString())°"
        self.currentMaxWeather.value = "\(currentWeather.temp_max.doubleToString())°"
        self.currentMinWeather.value = "\(currentWeather.temp_min.doubleToString())°"
        self.currentImageWeather.value = UIImage(named: "\(currentWeather.weather?.icon ?? "01n")-1.png")
        self.currentDescription.value = currentWeather.weather?.description.capitalizingFirstLetter()
        self.currentPressure.value = "\(currentWeather.pressurre.doubleToString())мм"
        self.currentWindSpeed.value = "\(currentWeather.speed)м/с"
        self.currentHumidity.value = "\(currentWeather.humidity.doubleToString())%"
        self.backgroundImageView.value = UIImage(named: "\(currentWeather.weather?.icon ?? "01n")-2")
        self.reloadTableView?()
    }

    func getWeather () {
        if weather.lat != nil && weather.lon != nil {
            weather.withGeolocationWeather {
                self.addWeatherSettings()
            }
        } else {
            weather.noGeolocationWeather {
                self.addWeatherSettings()
            }
     
        }
    }
    
    private func dateFormater(date: TimeInterval, dateFormat: String) -> String {
        let dateText = Date(timeIntervalSince1970: date )
        let formater = DateFormatter()
        formater.timeZone = TimeZone(secondsFromGMT: weather.currentWeatherObject?.timezone ?? 0)
        formater.dateFormat = dateFormat
        return formater.string(from: dateText)
        
    }
    
    //MARK: - collection cells configure
    func dailyConfigureCell (cell: DailyCollectionViewCell, indexPath: IndexPath) -> DailyCollectionViewCell {
        
        cell.configure(dailyWeatherObject: weather.dailyWeatherObject!, indexPath: indexPath.row)
        cell.dailyDate.text = dateFormater(date: (weather.dailyWeatherObject?.dt[indexPath.row])!, dateFormat: "E d MMM")
        return cell
    }
    
    func hourlyConfigureCell (cell: HourlyCollectionViewCell, indexPath: IndexPath) -> HourlyCollectionViewCell {
        
        cell.configure(dailyWeatherObject: weather.dailyWeatherObject!, indexPath: indexPath.row)
        cell.hourlyTime.text = dateFormater(date: (weather.dailyWeatherObject?.hourly?.dt[indexPath.row])!, dateFormat: "HH:mm")
        return cell
    }
    
}
//MARK: - Extensions
extension WeatherViewModel: SearchViewModelDelegate {
    func setLocation(_ lat: Double, _ lon: Double) {
        self.weather.lon = lon
        self.weather.lat = lat
        getWeather()
    }
}

extension WeatherViewModel: CLLocationManagerDelegate{
    private func actualLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        weather.lat = location.latitude
        weather.lon = location.longitude
        locationManager.stopUpdatingLocation()
    }
}
