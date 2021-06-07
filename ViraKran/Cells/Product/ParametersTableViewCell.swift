//
//  ParametersTableViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 18.05.2021.
//

import UIKit

struct ParametersTableViewCellViewModel{
    let title: String
    let value: String
}

class ParametersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var value: UILabel!
    static let identifier = "ParameterTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ParametersCell", bundle: nil)
    }
}
