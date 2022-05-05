
import Foundation
import Network
import CoreLocation

enum keys {
    static let firstStart = "firstStart"
}

class LoadingViewModel: NSObject {
    
    var showLoading: (()->())?
    var hideLoading: (()->())?
    var showError: (()->())?
    var loadWeatherController: (()->())?
    var loadStartController: (()->())?
    var weather = WeatherModel()
    
    private let locationManager = CLLocationManager()
    private let monitor = NWPathMonitor()
    
    func checkFirstStart(){
        showLoading?()
        CityModel.shared.getCity()
        if  UserDefaults.standard.value(forKey: keys.firstStart) == nil {
            loadStartController?()
        } else {
            checkNetwork()
        }
    }
    
   private func checkNetwork(){
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.actualLocation()
                if self.locationManager.authorizationStatus == .denied {
                    self.getWeather()
                }
            } else {
                DispatchQueue.main.async {
                    self.showError?()
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
    }

    private func getWeather() {
        if weather.lat != nil && weather.lon != nil {
            self.weather.withGeolocationWeather {
                self.hideLoading?()
                self.loadWeatherController?()
            }
        } else {
            self.weather.noGeolocationWeather {
                self.hideLoading?()
                self.loadWeatherController?()
            }
        }
    }
}

extension LoadingViewModel:  CLLocationManagerDelegate  {
    
    private func actualLocation() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        weather.lat = location.latitude
        weather.lon = location.longitude
        locationManager.stopUpdatingLocation()
        getWeather()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                getWeather()
                debugPrint("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                debugPrint("Access")
            @unknown default:
                break
            }
        } else {
           debugPrint("Location services are not enabled")
        }
    }
}

