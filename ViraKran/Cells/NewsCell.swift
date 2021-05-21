//
//  NewsCell.swift
//  ViraKran
//
//  Created by Stanislav on 11.02.2021.
//

import UIKit
import SDWebImage

class NewsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textArticle: UILabel!
    @IBOutlet weak var imagePlace: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    func setContent(title: String, text: String, imageLink: String, dateLabel: Date){
        self.titleLabel.text = title
        self.textArticle.text = text
        self.dateLabel.text = "\(dateLabel)"
        let transformer = SDImageResizingTransformer(size: CGSize(width: 550, height: 300), scaleMode: .fill)
        self.imagePlace.sd_setImage(with: URL(string: imageLink), placeholderImage: nil, context: [.imageTransformer: transformer])
    }

}
