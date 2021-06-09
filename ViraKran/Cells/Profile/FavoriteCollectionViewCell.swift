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
    
    @IBOutlet weak var labelName: UILabel!
    var imageURL: URL?{
            didSet{
                let transformer = SDImageResizingTransformer(size: CGSize(width: 400, height: 400), scaleMode: .aspectFit)
                self.standImage.sd_setImage(with: imageURL, placeholderImage: nil, context: [.imageTransformer: transformer])
            }
        }
}
