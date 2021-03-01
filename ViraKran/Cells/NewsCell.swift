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
        //guard let imageURL = URL(string: imageLink) else {return}
        let imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/vira-kran.appspot.com/o/%D0%9A%D1%80%D0%B0%D0%BD%D1%8B%2F%D0%91%D0%B0%D1%88%D0%B5%D0%BD%D0%BD%D1%8B%D0%B5%D0%9A%D1%80%D0%B0%D0%BD%D1%8B%2Fdakodnomufoto.jpg?alt=media&token=abba315e-12c3-441a-a1b6-60da8b8639c5")
        self.imagePlace.sd_setImage(with:imageURL)
    }
}
