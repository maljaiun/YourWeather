
import Foundation
import UIKit
import CoreLocation

class StartViewModel {
    
    var weather = WeatherModel()
    
    func saveLocation(_ location: CLLocationCoordinate2D ) {
        weather.lat = location.latitude
        weather.lon = location.longitude
    }
    
    func getWeather(compelition: @escaping () -> ()) {
        if weather.lat != nil && weather.lon != nil {
            weather.withGeolocationWeather {
                compelition()
            }
        } else {
            weather.noGeolocationWeather {
                compelition()
            }
     
        }
    }
    
}
