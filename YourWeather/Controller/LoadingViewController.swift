//
//  LoadingViewController.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 23.02.2022.
//

import UIKit
import CoreLocation
import Network

class LoadingViewController: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - vars/lets
    let monitor = NWPathMonitor()
    let locationManager = CLLocationManager()
    
    var weather = WeatherModel()
    
    //MARK: - lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFirstStartStatus()
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
    }
    
    //MARK: - flow func
    private func checkFirstStartStatus() {
        if  UserDefaults.standard.value(forKey: keys.firstStart) == nil {
            guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.startViewController) as? StartViewController else { return }
            navigationController?.pushViewController(controller, animated: false)
        } else {
            checkNetwork()
        }
    }
    
    // internet connection
    private func checkNetwork(){
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.checkLocationStatusEnable()
            } else {
                DispatchQueue.main.async {
                    self.addAlert()
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    private func addAlert() {
        let alert = UIAlertController(title: "Нет соединения с интернетом", message: "Для корректного отображения данных требуется доступ к сети интернет", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: { _ in
            self.loadWeatherController()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //check Location Status
    private func checkLocationStatusEnable() {
        //как это правильно работает?
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                self.actualLocation()
                break
            case  .restricted, .denied:
                DispatchQueue.main.async {
                    self.addWeather()
                }
            case .authorizedAlways, .authorizedWhenInUse:
                self.actualLocation()
            @unknown default:
                fatalError()
            }
            
        } else {
            print("Location services are not enabled")
        }
    }
    
    private func addWeather() {
        if weather.lat != nil && weather.lon != nil {
            self.weather.withGeolocationWeather {
                self.loadWeatherController()
            }
        } else {
            self.weather.noGeolocationWeather {
                self.loadWeatherController()
            }
        }
    }
    
    private func loadWeatherController() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.weatherViewController) as? WeatherViewController else { return }
        controller.weather = weather
        activityIndicator.stopAnimating()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
//MARK: - Extensions

//CLLocationManagerDelegate
extension LoadingViewController:  CLLocationManagerDelegate  {
    private func actualLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        self.weather.lat = location.latitude
        self.weather.lon = location.longitude
        locationManager.stopUpdatingLocation()
        self.addWeather()
    }
}

