//
//  SelfLocationTableViewCell.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 28.02.2022.
//

import UIKit

class SelfLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    func configure() {
        self.locationLabel.text = "Use current location".localize
    }
}
