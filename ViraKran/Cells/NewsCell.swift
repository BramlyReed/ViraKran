//
//  NewsCell.swift
//  ViraKran
//
//  Created by Stanislav on 11.02.2021.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setText(title: String){
        self.titleLabel.text = title
    }
}
