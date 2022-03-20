//
//  StartViewController.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 17.02.2022.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation

class StartViewController: UIViewController{

    //MARK: - IBOutlets
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    //MARK: - vars/lets
    let locationManager = CLLocationManager()
    var weather = WeatherModel()
    
    //MARK: - lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        actualLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideoBackground()
        mainSettings()
    }
    
    //MARK: - IBActions
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.weatherViewController) as? WeatherViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        controller.weather = weather
        navigationController?.pushViewController(controller, animated: true)
    }

    //MARK: - flow func
    private func mainSettings() {
        self.continueButton.addButtonRadius()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.greetingsLabel.text = "Welcome!".localize
        self.descriptionLabel.text = "The “YouWeather” app provides accurate forecast and weather alerts wherever you are. We must be allowed to use your Location Services.".localize
        self.continueButton.setTitle("Next".localize, for: .normal)
        self.privacyLabel.text = "We use and share the precise location of your device based оn our Privacy Policy".localize
    }
    
    //Background video
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: .zero)
    }
    
    private func playVideoBackground() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp4") else { return }
        let player = AVPlayer(url: url)
        let videoLayer = AVPlayerLayer(player: player)
        
        videoLayer.videoGravity = .resizeAspectFill
        player.volume = 0

        player.actionAtItemEnd = .none
        videoLayer.frame = self.view.layer.bounds
        self.view.backgroundColor = .clear
        self.view.layer.insertSublayer(videoLayer, at: 0)
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem)
        player.play()
    }
    
    private func addWeather() {
        if weather.lat != nil && weather.lon != nil {
            weather.withGeolocationWeather {
            }
        } else {
            weather.noGeolocationWeather {
                
            }
        }
    }

}

extension StartViewController:  CLLocationManagerDelegate  {
    private func actualLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        weather.lat = location.latitude
        weather.lon = location.longitude
        locationManager.stopUpdatingLocation()
        addWeather()
    }
}
