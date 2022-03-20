//
//  UIimage+extension.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 28.02.2022.
//

import Foundation
import UIKit

extension UIImageView {
    func addImageGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.opacity =  0.9
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0.3)
        gradient.frame = self.bounds
        gradient.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
}
