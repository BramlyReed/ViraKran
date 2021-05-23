//
//  FavoriteCollectionViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 23.05.2021.
//

import UIKit
import SDWebImage

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var standImage: UIImageView!
    var imageURL: URL?{
        didSet{
            print(imageURL)
            self.standImage.sd_setImage(with: imageURL)
        }
    }
}
