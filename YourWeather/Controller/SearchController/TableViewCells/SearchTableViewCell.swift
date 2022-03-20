//
//  SearchTableViewCell.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 21.02.2022.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var countryName: UILabel!
    
    func configure(filteredCities: CityObject) {
        self.cityName.text = filteredCities.name
        self.countryName.text = filteredCities.country
        self.backgroundColor = .clear
    }

}
