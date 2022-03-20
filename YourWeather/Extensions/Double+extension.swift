//
//  Double+extension.swift
//  YourWeather
//
//  Created by Kirill Sytkov on 28.02.2022.
//

import Foundation

extension Double {
    func doubleToString() -> String {
        return String(format: "%.0f", self)
    }
}
