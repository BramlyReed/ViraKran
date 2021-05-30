//
//  NewsCell.swift
//  ViraKran
//
//  Created by Stanislav on 11.02.2021.
//

import UIKit
import SDWebImage

class NewsCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textArticle: UILabel!
    @IBOutlet weak var imagePlace: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    func setContent(title: String, text: String, imageLink: String, dateLabel: Date){
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = .white
        self.titleLabel.text = title
        self.textArticle.text = text
        let datetime = dateLabel
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.setLocalizedDateFormatFromTemplate("dd-MM-yyyy HH:mm")
        self.dateLabel.text = formatter.string(from: datetime)
        let transformer = SDImageResizingTransformer(size: CGSize(width: 550, height: 300), scaleMode: .fill)
        self.imagePlace.sd_setImage(with: URL(string: imageLink), placeholderImage: nil, context: [.imageTransformer: transformer])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }

}
