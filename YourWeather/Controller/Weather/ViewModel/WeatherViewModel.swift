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
    var currentWeatherObject = Bindable<CurrentWeather?>(nil)
    var dailyCollectionView = Bindable<DailyWeather?>(nil)
    
    private let locationManager = CLLocationManager()
    var weather = WeatherModel()
    var reloadCollectionView: (()->())?
    
    var numberOfDailyCells: Int {
        return weather.dailyWeather?.daily.count ?? 8
    }
    
    var numberOfHourlyCells: Int {
        return weather.dailyWeather?.hourly.count ?? 24
    }
    
    
    //MARK: - flow func
    func addWeatherSettings() {
        guard let currentWeather = self.weather.currentWeather else { return }
        self.navigationBarTitle.value = currentWeather.name
        self.currentTime.value = dateFormater(date: currentWeather.dt, dateFormat: "HH:mm E")
        self.currentTemperature.value = "\(currentWeather.main.temp.doubleToString())°"
        self.currentFeelingWeather.value = "\(currentWeather.main.feels_like.doubleToString())°"
        self.currentMaxWeather.value = "\(currentWeather.main.temp_max.doubleToString())°"
        self.currentMinWeather.value = "\(currentWeather.main.temp_min.doubleToString())°"
        self.currentImageWeather.value = UIImage(named: "\(currentWeather.weather.first!.icon)-1.png")
        self.currentDescription.value = currentWeather.weather.first!.description.capitalizingFirstLetter()
        self.currentPressure.value = "\(currentWeather.main.pressure.doubleToString())мм"
        self.currentWindSpeed.value = "\(currentWeather.wind.speed)м/с"
        self.currentHumidity.value = "\(currentWeather.main.humidity.doubleToString())%"
        self.backgroundImageView.value = UIImage(named: "\(currentWeather.weather.first!.icon)-2")
        self.reloadCollectionView?()
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
        formater.timeZone = TimeZone(secondsFromGMT: weather.currentWeather?.timezone ?? 0)
        formater.dateFormat = dateFormat
        return formater.string(from: dateText)
        
    }
    
    //MARK: - collection cells configure
    func dailyConfigureCell (cell: DailyCollectionViewCell, indexPath: IndexPath) -> DailyCollectionViewCell {
        cell.configure(daily: weather.dailyWeather!.daily[indexPath.row], indexPath: indexPath.row)
        cell.dailyDate.text = dateFormater(date: (weather.dailyWeather!.daily[indexPath.row].dt), dateFormat: "E d MMM")
        return cell
    }
    
    
    func hourlyConfigureCell (cell: HourlyCollectionViewCell, indexPath: IndexPath) -> HourlyCollectionViewCell {
        cell.configure(hourly: weather.dailyWeather!.hourly[indexPath.row], indexPath: indexPath.row)
        cell.hourlyTime.text = dateFormater(date: (weather.dailyWeather!.hourly[indexPath.row].dt), dateFormat: "HH:mm")
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
