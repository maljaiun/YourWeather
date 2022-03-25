//
//  WeatherViewController.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 17.02.2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var updateScrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var actualWeatherView: UIView!
    @IBOutlet weak var shadowConteinerView: UIView!
    @IBOutlet weak var currentPressure: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var currentHumidity: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var currentDescription: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentFeelingWeather: UILabel!
    @IBOutlet weak var feelingLabel: UILabel!
    @IBOutlet weak var currentImageWeather: UIImageView!
    @IBOutlet weak var currentMinWeather: UILabel!
    @IBOutlet weak var currentMaxWeather: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var currentWindSpeed: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    //MARK: - vars/lets
    private let refreshControl = UIRefreshControl()
    private let locationManager = CLLocationManager()
    var weather = WeatherModel()
    
    //MARK: - lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: keys.firstStart)
        mainSettings()
        refreshControllSettings()
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 50, y: 200, width: 100, height: 30)
        button.setTitle("Test Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addWeather()
        updateScrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        let numbers = [0]
        let _ = numbers[1]
    }
    
    
    
    //MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.searchViewController) as? SearchViewController else { return }
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: - flow func
    // UISettings
    private func mainSettings() {
        self.shadowConteinerView.layer.cornerRadius = self.shadowConteinerView.frame.height / 2
        self.shadowConteinerView.dropShadow()
        self.actualWeatherView.layer.cornerRadius = self.actualWeatherView.frame.height / 2
        self.actualWeatherView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.currentImageWeather.contentMode = .scaleAspectFit
        self.backgroundImageView.addImageGradient()
        self.maxTempLabel.text = "Max".localize
        self.minTempLabel.text = "Min".localize
        self.feelingLabel.text = "Feeling".localize
        self.pressureLabel.text = "Pressure".localize
        self.windSpeedLabel.text = "Wind speed".localize
        self.humidityLabel.text = "Humidity".localize
    }
    
    private func addWeatherSettings() {
        guard let currentWeather = self.weather.currentWeatherObject else { return }
        self.navigationBar.title = currentWeather.name
        self.currentTime.text = weather.dateFormater(date: currentWeather.dt, dateFormat: "HH:mm E")
        self.currentTemperature.text = "\(currentWeather.temp.doubleToString())°"
        self.currentFeelingWeather.text = "\(currentWeather.feels_like.doubleToString())°"
        self.currentMaxWeather.text = "\(currentWeather.temp_max.doubleToString())°"
        self.currentMinWeather.text = "\(currentWeather.temp_min.doubleToString())°"
        self.currentImageWeather.image = UIImage(named: "\(currentWeather.weather?.icon ?? "01n")-1.png")
        self.currentDescription.text = currentWeather.weather?.description.capitalizingFirstLetter()
        self.currentPressure.text = "\(currentWeather.pressurre.doubleToString())мм"
        self.currentWindSpeed.text = "\(currentWeather.speed)м/с"
        self.currentHumidity.text = "\(currentWeather.humidity.doubleToString())%"
        self.backgroundImageView.image = UIImage(named: "\(currentWeather.weather?.icon ?? "01n")-2")
        self.backgroundImageAnimate()
    }
    
    private func backgroundImageAnimate() {
        self.backgroundImageView.frame.origin.x = 0
        UIView.animate(withDuration: 10, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.backgroundImageView.frame.origin.x -= 100
        }, completion: nil)
    }
    
    private func addWeather() {
        if weather.lat != nil && weather.lon != nil {
            addWeatherSettings()
            reloadAllCollectionView()
        } else {
            weather.noGeolocationWeather {
                self.addWeatherSettings()
                self.reloadAllCollectionView()
            }
        }
    }
    private func reloadAllCollectionView() {
        dailyCollectionView.reloadData()
        hourlyCollectionView.reloadData()
    }
    // Pull to refresh
    @objc private func refreshWeatherData(_ sender: Any) {
        fetchWeatherData()
    }
    
    private func fetchWeatherData() {
        weather.withGeolocationWeather {
            self.addWeatherSettings()
            self.reloadAllCollectionView()
        }
        updateScrollView.refreshControl!.endRefreshing()
    }
    
    private func refreshControllSettings() {
        refreshControl.tintColor = .white
    }
}

//MARK: - Extensions
//Delegate SearchViewController
extension WeatherViewController: SearchViewControllerDelegate {
    func setLocation(_ lat: Double, _ lon: Double) {
        weather.lat = lat
        weather.lon = lon
        weather.withGeolocationWeather {
            self.addWeatherSettings()
            self.reloadAllCollectionView()
        }
    }
}

// CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{
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

//collection View
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dailyCollectionView {
            return weather.dailyWeatherObject?.icon.count ?? 8
            
        } else {
            return weather.dailyWeatherObject?.hourly?.temp.count ?? 24
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == hourlyCollectionView {
            guard let hourlyCell = hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.cells.hourlyCollectionViewCell, for: indexPath) as? HourlyCollectionViewCell
            else { return UICollectionViewCell()}
            
            if let dailyWeatherObject = weather.dailyWeatherObject {
                hourlyCell.configure(dailyWeatherObject: dailyWeatherObject, indexPath: indexPath.item)
                hourlyCell.hourlyTime.text = weather.dateFormater(date: dailyWeatherObject.hourly?.dt[indexPath.item] ?? 0, dateFormat: "HH:mm")
            }
            return hourlyCell
            
        } else {
            guard let dailyCell = dailyCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.cells.dailyCollectionViewCell, for: indexPath) as? DailyCollectionViewCell
            else { return UICollectionViewCell ()}
            
            if let dailyWeatherObject = weather.dailyWeatherObject {
                dailyCell.configure(dailyWeatherObject: dailyWeatherObject, indexPath: indexPath.item)
                dailyCell.dailyDate.text = weather.dateFormater(date: dailyWeatherObject.dt[indexPath.item], dateFormat: "E d MMM")
            }
            return dailyCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == dailyCollectionView {
            return CGSize(width: 128, height: 50)
        } else {
            return CGSize(width: 70, height: 100)
        }
    }
}
