//
//  NewsDetailsView.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 04.02.2023.
//

import UIKit

protocol ArticleDetailsViewDelegate: AnyObject {
    func articleDetailsViewDidTapLinkButton(_ view: ArticleDetailsView)
}

class ArticleDetailsView: UIView {

    weak var delegate: ArticleDetailsViewDelegate?
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let linkButton: UIButton = {
        let button = UIButton()
        button.setTitle("Click to read more...", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(dateLabel)
        addSubview(sourceLabel)
        addSubview(linkButton)
        addSubview(articleImageView)
        linkButton.addTarget(self, action: #selector(didTapLinkButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        articleImageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        nameLabel.frame = CGRect(x: 10,
                                 y: articleImageView.bottom + 10,
                                 width: width-20,
                                 height: 88)
        
        descriptionLabel.frame = CGRect(x: 10,
                                        y: nameLabel.bottom,
                                        width: width-20,
                                        height: 66)
        
        dateLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 44)
        
        sourceLabel.frame = CGRect(x: 10, y: dateLabel.bottom, width: width-20, height: 44)
        
        linkButton.frame = CGRect(x: 10, y: sourceLabel.bottom, width: width-20, height: 44)
    }
    
    func configure(with viewModel: ArticleDetailsViewViewModel) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        sourceLabel.text = viewModel.source
        
        if let date = viewModel.date {
            dateLabel.text = dateConverter(for: date)
        }
        else {
            dateLabel.text = "No date info"
        }
        
        if let data = viewModel.imageData {
            articleImageView.image = UIImage(data: data)
        }
        else {
            articleImageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc private func didTapLinkButton() {
        delegate?.articleDetailsViewDidTapLinkButton(self)
    }
    
    private func dateConverter(for string: String) -> String {
        let date = dateFromString(string: string)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y, HH:mm E"
        return formatter.string(from: date)
    }
    
    private func dateFromString(string: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: string) ?? Date.now
        return date
    }
}
