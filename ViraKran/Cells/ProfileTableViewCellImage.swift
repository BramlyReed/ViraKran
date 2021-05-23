//
//  ProfileTableViewCellImage.swift
//  ViraKran
//
//  Created by Stanislav on 22.05.2021.
//

import UIKit
import SDWebImage
class ProfileTableViewCellImage: UITableViewCell {

    static let identifier = "ProfileTableViewCellImage"
    
    @IBOutlet weak var profileImage: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileTableViewCellImage", bundle: nil)
    }
    
    func configure(with imageLink: String) {
        let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
        self.profileImage.sd_setImage(with: URL(string: imageLink), placeholderImage: nil, context: [.imageTransformer: transformer])
    }
}
