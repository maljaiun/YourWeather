//
//  DailyCollectionViewCell.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 22.02.2022.
//

import UIKit

class DailyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dailyImage: UIImageView!
    @IBOutlet weak var dailyDate: UILabel!
    @IBOutlet weak var dailyMaxTemp: UILabel!
    @IBOutlet weak var dailyMinTemp: UILabel!
    
    func configure(daily: Daily, indexPath: Int) {
        dailyDate.textColor = .white
        dailyMaxTemp.textColor = .white
        dailyMinTemp.textColor = .white
        dailyImage.contentMode = .scaleAspectFit
        dailyImage.image = UIImage(named: "\(daily.weather.first!.icon)-1.png")
        dailyMinTemp.text = "\(daily.temp.min.doubleToString())°"
        dailyMaxTemp.text = "\(daily.temp.max.doubleToString())°"
    }
    
}
