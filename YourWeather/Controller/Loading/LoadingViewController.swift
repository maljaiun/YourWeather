//
//  LoadingViewController.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 23.02.2022.
//

import UIKit

class LoadingViewController: UIViewController{
    
    //MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - vars/lets
    var viewModel = LoadingViewModel()
    
    //MARK: - lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - flow func
    private func bind() {
        viewModel.showLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }
        viewModel.hideLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        viewModel.showError = {
            let alert = UIAlertController(title: "Нет соединения с интернетом", message: "Для корректного отображения данных требуется доступ к сети интернет", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: { _ in
                self.viewModel.loadWeatherController?()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        viewModel.loadStartController = {
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: Constants.startViewController) as? StartViewController else { return }
            self.navigationController?.pushViewController(controller, animated: false)
        }
        viewModel.loadWeatherController = {
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: Constants.weatherViewController) as? WeatherViewController else { return }
            controller.viewModel.weather = self.viewModel.weather
            self.navigationController?.pushViewController(controller, animated: true)
        }
        viewModel.checkFirstStart()
    }
}


