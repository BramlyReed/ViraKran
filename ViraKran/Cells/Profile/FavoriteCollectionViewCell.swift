//
//  FavoriteCollectionViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 23.05.2021.
//

import UIKit
import SDWebImage

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var standImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        standImage.layer.cornerRadius = standImage.frame.height/2
    }
    
    func configure(imageURL: URL?){
        self.standImage.sd_setImage(with: imageURL)
        
    }
}
