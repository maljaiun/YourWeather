
import Foundation
import CoreLocation

protocol SearchViewModelDelegate: AnyObject {
    func setLocation(_ lat: Double, _ lon: Double)
}

class SearchViewModel {
    
    var reloadTablView: (()->())?
    weak var delegate: SearchViewModelDelegate?
    private var cities: [CityObject]?
    private var filteredCities = [CityObject]()
    private var lat: Double?
    private var lon: Double?
    var cellViewModel = [SearchCellViewModel]() {
        didSet {
            self.reloadTablView?()
        }
    }
    
    var numberOfCell: Int {
        if filteredCities.count > 20 {
            return 20
        } else if filteredCities.count > 0 {
            return filteredCities.count
        } else {
            return 1
        }
    }
    
    func getLocation(location: CLLocationCoordinate2D) {
        self.lat = location.latitude
        self.lon = location.longitude
    }
    
    func getCity() {
        DispatchQueue.global().async {
            CityManager.shared.getCity { [weak self] newCity in
                self?.cities = newCity
                self?.createCell()
            }
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        if filteredCities.isEmpty {
            self.delegate?.setLocation(self.lat!, self.lon!)
        } else {
            self.delegate?.setLocation(filteredCities[indexPath.row].lat, filteredCities[indexPath.row].lon)
        }
    }
    
    func searchCity(text: String) {
        guard let cities = cities else { return }
        filteredCities = cities.filter({ (city: CityObject) in
            if text.count > 2 && city.name.lowercased().contains(text.lowercased()) {
                return true
            }
            return false
        })
        filteredCities.sort(by: {$0.name.count < $1.name.count})
        createCell()
        reloadTablView?()
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> SearchCellViewModel {
        return cellViewModel[indexPath.row]
    }
    
    func filteredCityIsEmpty() -> Bool {
        filteredCities.isEmpty
    }
    
    func createCell(){
        var viewModelCell = [SearchCellViewModel]()
        for city in filteredCities {
            viewModelCell.append(SearchCellViewModel(city: city.name, country: city.country))
        }
        cellViewModel = viewModelCell
    }
    
}

struct SearchCellViewModel {
    var city: String
    var country: String
}

