//
//  CityManager.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 21.02.2022.
//

import Foundation

class CityManager {
    
    static let shared = CityManager()
    private init () {}
    
    func getCity(completion: @escaping ([CityObject]) -> ()) {
        guard let path = Bundle.main.path(forResource: "city", ofType: "json") else { return }

        var newCity = [CityObject]()
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonSerilization = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            if let json = jsonSerilization as? [[String:Any]] {
                for json in json {
                    guard let coord = json["coord"] as? [String:Any] else { return }
                    if let name = json["name"] as? String,
                       let country = json["country"] as? String,
                       let lon = coord["lon"] as? Double,
                        let lat = coord["lat"] as? Double{
                        let city = CityObject()
                        city.lon = lon
                        city.lat = lat
                        city.name = name
                        city.country = country
                        newCity.append(city)
                    }
                }
                completion(newCity)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
