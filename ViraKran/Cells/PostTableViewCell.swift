//
//  PostTableViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 22.05.2021.
//

import UIKit
import SDWebImage
class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var dateSent: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    func configure(img: URL, usrN: String, date: String, com: String){
        self.profileImage.sd_setImage(with: img)
        self.userName.text = usrN
        self.dateSent.text = date
        self.comment.text = com
    }
}
