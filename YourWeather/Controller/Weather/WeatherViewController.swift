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
    
    var viewModel = WeatherViewModel()

    //MARK: - lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: keys.firstStart)
        bind()
        refreshControllSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        viewModel.addWeatherSettings()
        backgroundImageAnimate()
        updateScrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
 
    
    //MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.searchViewController) as? SearchViewController else { return }
        controller.viewModel.delegate = self.viewModel
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - flow func
    // UISettings
    private func updateUI() {
        self.shadowConteinerView.layer.cornerRadius = self.shadowConteinerView.frame.height / 2
        self.shadowConteinerView.dropShadow()
        self.actualWeatherView.layer.cornerRadius = self.actualWeatherView.frame.height / 2
        self.actualWeatherView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.navigationBar.hidesBackButton = true
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
    
    private func backgroundImageAnimate() {
        self.backgroundImageView.frame.origin.x = 0
        UIView.animate(withDuration: 10, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.backgroundImageView.frame.origin.x -= 100
        }, completion: nil)
    }

    private func reloadWeatherView() {
        viewModel.addWeatherSettings()
        self.backgroundImageAnimate()

    }
    
    // Pull to refresh
    @objc private func refreshWeatherData(_ sender: Any) {
        fetchWeatherData()
    }
    
    private func fetchWeatherData() {
        viewModel.getWeather()
        updateScrollView.refreshControl!.endRefreshing()
    }
    
    private func refreshControllSettings() {
        refreshControl.tintColor = .white
    }
    
    private func bind() {
        self.viewModel.navigationBarTitle.bind { [weak self] navigationBarTitle in
            self?.navigationBar.title = navigationBarTitle
        }
        self.viewModel.currentPressure.bind { [weak self] currentPressure in
            self?.currentPressure.text = currentPressure
        }
        self.viewModel.currentHumidity.bind { [weak self] currentHumidity in
            self?.currentHumidity.text = currentHumidity
        }
        self.viewModel.currentDescription.bind { [weak self] currentDescription in
            self?.currentDescription.text = currentDescription
        }
        self.viewModel.currentTemperature.bind { [weak self] currentTemperature in
            self?.currentTemperature.text = currentTemperature
        }
        self.viewModel.currentFeelingWeather.bind { [weak self] currentFeelingWeather in
            self?.currentFeelingWeather.text = currentFeelingWeather
        }
        self.viewModel.currentImageWeather.bind { [weak self] currentImageWeather in
            self?.currentImageWeather.image = currentImageWeather
        }
        self.viewModel.currentMinWeather.bind { [weak self] currentMinWeather in
            self?.currentMinWeather.text = currentMinWeather
        }
        self.viewModel.currentMaxWeather.bind { [weak self] currentMaxWeather in
            self?.currentMaxWeather.text = currentMaxWeather
        }
        self.viewModel.currentWindSpeed.bind { [weak self] currentWindSpeed in
            self?.currentWindSpeed.text = currentWindSpeed
        }
        self.viewModel.currentTime.bind { [weak self] currentTime in
            self?.currentTime.text = currentTime
        }
        self.viewModel.backgroundImageView.bind { [weak self] backgroundImageView in
            self?.backgroundImageView.image = backgroundImageView
        }
        self.viewModel.reloadTableView = {
            DispatchQueue.main.async {
                self.dailyCollectionView.reloadData()
                self.hourlyCollectionView.reloadData()
            }
        }
    }
}


//MARK: - Extensions
// CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{
    private func actualLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        viewModel.getLocation(location)
        locationManager.stopUpdatingLocation()
    }
}

//collection View
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == dailyCollectionView {
            return viewModel.numberOfDailyCells
        } else {
            return viewModel.numberOfHourlyCells
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == hourlyCollectionView {
            
            guard let hourlyCell = hourlyCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.cells.hourlyCollectionViewCell, for: indexPath) as? HourlyCollectionViewCell
            else { return UICollectionViewCell()}
            
            return viewModel.hourlyConfigureCell(cell: hourlyCell, indexPath: indexPath)
            
        } else {
            
            guard let dailyCell = dailyCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.cells.dailyCollectionViewCell, for: indexPath) as? DailyCollectionViewCell
            else { return UICollectionViewCell ()}
            
            return viewModel.dailyConfigureCell(cell: dailyCell, indexPath: indexPath)
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
