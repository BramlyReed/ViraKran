//
//  PhotoCollectionViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 17.05.2021.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PhotoCollectionViewCell"
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func configure(with imageLink: String){
        //let transformer = SDImageResizingTransformer(size: CGSize(width: 1000, height: 800), scaleMode: .fill)
        //imageView.sd_setImage(with: URL(string:imageLink), placeholderImage: nil, context: [.imageTransformer: transformer])
        imageView.sd_setImage(with: URL(string:imageLink))
    }
}
