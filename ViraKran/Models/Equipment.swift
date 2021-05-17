//
//  Equipment.swift
//  ViraKran
//
//  Created by Stanislav on 12.05.2021.
//

import Foundation
import UIKit

class Equipment{
    var title = ""
    var featuredImage: UIImage
    var color: UIColor
    
    init(title: String, featuredImage: UIImage, color: UIColor) {
        self.title = title
        self.featuredImage = featuredImage
        self.color = color
    }
    static func fetchEquipments() -> [Equipment]{
        return [
            Equipment(title: "Первый", featuredImage: UIImage(named: "colorful kran")!, color: UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 0.7)),
            Equipment(title: "Второй", featuredImage: UIImage(named: "colorful kran")!, color: UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 0.7)),
            Equipment(title: "Третий", featuredImage: UIImage(named: "colorful kran")!, color: UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 0.7)),
            Equipment(title: "Четвертый", featuredImage: UIImage(named: "colorful kran")!, color: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 0.8))
        ]
    }
}
