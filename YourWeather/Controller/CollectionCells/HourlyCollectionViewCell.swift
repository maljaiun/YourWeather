//
//  HourlyCollectionViewCell.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 22.02.2022.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hourlyImageVew: UIImageView!
    @IBOutlet weak var hourlyTemp: UILabel!
    @IBOutlet weak var hourlyTime: UILabel!
    
    func configure(dailyWeatherObject: DailyWeatherObject, indexPath: Int) {
        hourlyTemp.textColor = .white
        hourlyTime.textColor = .white
        hourlyImageVew.contentMode = .scaleAspectFit
        hourlyImageVew.image = UIImage(named: "\(dailyWeatherObject.hourly?.icon[indexPath] ?? "05n")-1.png")
        hourlyTemp.text = "\(dailyWeatherObject.hourly?.temp[indexPath].doubleToString() ?? "0")°"
    }
}
