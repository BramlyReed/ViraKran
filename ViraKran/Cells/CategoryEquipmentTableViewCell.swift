//
//  CategoryEquipmentTableViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 19.05.2021.
//

import UIKit
import SDWebImage
class CategoryEquipmentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(picture: String, title: String) {
        let transformer = SDImageResizingTransformer(size: CGSize(width: 550, height: 300), scaleMode: .fill)
        self.pictureView.sd_setImage(with: URL(string: picture), placeholderImage: nil, context: [.imageTransformer: transformer])
        titleLabel.text = title
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        cardView.layer.shadowOpacity = 5.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
    }
}
