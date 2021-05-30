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
    static let identifier = "ParameterTableViewCell"
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    let labelValue: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(labelTitle)
        contentView.addSubview(labelValue)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let Size: CGFloat = contentView.frame.size.height
        labelTitle.frame = CGRect(x: 25, y: 0, width: 200, height: Size)
        labelValue.frame = CGRect(x: (labelTitle.frame.width + 30), y: 0, width: contentView.frame.size.width - 20 - Size, height: Size)
    }
    func configure(with viewModel: ParametersTableViewCellViewModel) {
        labelTitle.text = viewModel.title
        labelValue.text = viewModel.value
    }
}
