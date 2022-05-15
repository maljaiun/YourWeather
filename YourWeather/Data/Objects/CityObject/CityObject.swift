//
//  CityObject.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 21.02.2022.
//

import Foundation

class CityObject: Codable{
    var name: String
    var country: String
    var coord: CoordCity
}

class CoordCity: Codable {
    var lat: Double
    var lon: Double
}
