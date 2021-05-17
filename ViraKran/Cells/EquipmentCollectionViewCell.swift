//
//  EquipmentCollectionViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 11.05.2021.
//

import Foundation
import UIKit

class EquipmentCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    
    
    var equipment: Equipment! {
        didSet{
            self.updateUI()
        }
    }
    func updateUI(){
        if let equipment = equipment{
            featuredImageView.image = equipment.featuredImage
            TitleLabel.text = equipment.title
        } else{
            featuredImageView.image = nil
            TitleLabel.text = nil
        }
    }
}
