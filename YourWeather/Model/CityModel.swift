//
//  CityModel.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 05.05.2022.
//

import Foundation

class CityModel {
    
    var cities: [CityObject]?
    
    static let shared = CityModel()
    private init () {}
    
    func getCity() {
        DispatchQueue.global().async {
            CityManager.shared.getCity { [weak self] newCity in
                self?.cities = newCity
            }
        }
    }
    
}
