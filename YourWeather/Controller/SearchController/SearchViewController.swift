//
//  SearchViewController.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 21.02.2022.
//

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate: AnyObject {
    func setLocation(_ lat: Double, _ lon: Double)
    
}

class SearchViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchNavigationBar: UINavigationBar!
    
    //MARK: - vars/lets
    weak var delegate: SearchViewControllerDelegate?
    
    private var cities: [CityObject]?
    private var filteredCities = [CityObject]()
    private let searchController = UISearchController(searchResultsController: nil)
    private let locationManager = CLLocationManager()
    private var lat: Double?
    private var lon: Double?
    
    //MARK: - lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        actualLocation()
        getCity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainSettings()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    //MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    //MARK: - flow func
    private func mainSettings() {
        self.view.backgroundColor = .clear
        self.searchNavigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.searchNavigationBar.topItem?.searchController = searchController
        self.searchNavigationBar.tintColor = .white
        searchController.searchResultsUpdater = self
        searchController.searchBar.isHidden = false
        searchController.searchBar.placeholder = "Search".localize
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.searchTextField.textColor = .white
        self.searchNavigationBar.topItem?.title = "Location".localize
        
    }
    
    private func getCity() {
        DispatchQueue.global().async {
            CityManager.shared.getCity { [weak self] newCity in
                self?.cities = newCity
            }
        }
    }
}

//MARK: - Extensions

extension SearchViewController: CLLocationManagerDelegate {
    private func actualLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else { return }
        self.lat = location.latitude
        self.lon = location.longitude
        locationManager.stopUpdatingLocation()
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text,
              let cities = cities else { return }
        
        filteredCities = cities.filter({ (city: CityObject) in
            if text.count > 2 && city.name.lowercased().contains(text.lowercased()) {
                return true
            }
            return false
        })
        filteredCities.sort(by: {$0.name.count < $1.name.count})
        searchTableView.reloadData()
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if filteredCities.count > 20 {
            return 20
        } else if filteredCities.count > 0 {
            return filteredCities.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredCities.isEmpty {
            guard let locationCell = tableView.dequeueReusableCell(withIdentifier: Constants.cells.selfLocationTableViewCell, for: indexPath) as? SelfLocationTableViewCell else { return UITableViewCell() }
            locationCell.configure()
            return locationCell
        } else {
            guard let searchCell = tableView.dequeueReusableCell(withIdentifier: Constants.cells.searchTableViewCell, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
            searchCell.configure(filteredCities: filteredCities[indexPath.row])
            return searchCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if filteredCities.isEmpty, let lat = lat ,let lon = lon {
            self.delegate?.setLocation(lat, lon)
            dismiss(animated: true)
        } else {
            self.delegate?.setLocation(filteredCities[indexPath.row].lat, filteredCities[indexPath.row].lon)
            dismiss(animated: true)
        }
        
    }
}

