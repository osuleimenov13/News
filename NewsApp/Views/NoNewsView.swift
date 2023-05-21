//
//  NoNewsView.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 05.02.2023.
//

import UIKit

class NoNewsView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.text = "No News"
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        clipsToBounds = true
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
    }
}
