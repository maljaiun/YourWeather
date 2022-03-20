//
//  UIButton+extension.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 20.02.2022.
//

import Foundation
import UIKit

extension UIButton {
    func addButtonRadius(_ radius: CGFloat = 15) {
        self.layer.cornerRadius = radius
        
    }
}
