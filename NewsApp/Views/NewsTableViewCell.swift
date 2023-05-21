//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 03.02.2023.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    static let identifier = "NewsTableViewCell"
    
    var viewsCount = 0
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private let viewsCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(viewsCountLabel)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height-10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        iconImageView.layer.masksToBounds = true
        
        titleLabel.frame = CGRect(x: iconImageView.right+10,
                                  y: 0,
                                  width: contentView.width-iconImageView.right-20,
                                  height: contentView.height * 0.6)
        
        viewsCountLabel.frame = CGRect(x: iconImageView.right+10,
                                       y: titleLabel.bottom,
                                       width: contentView.width-iconImageView.right-20,
                                       height: contentView.height * 0.4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        viewsCountLabel.text = nil
    }
    
    func configure(with viewModel: NewsTableViewCellViewModel) {
        titleLabel.text = viewModel.title
        viewsCountLabel.text = viewModel.viewsCount
        
        if let data = viewModel.imageData {
            iconImageView.image = UIImage(data: data)
        }
        else {
            iconImageView.image = UIImage(systemName: "photo")
        }
    }
}
