//
//  NewsDetailsViewController.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 04.02.2023.
//

import UIKit

class ArticleDetailsViewController: UIViewController, ArticleDetailsViewDelegate {

    private let article: Article
    
    private let articleDetailsView = ArticleDetailsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(articleDetailsView)
        articleDetailsView.configure(with: ArticleDetailsViewViewModel(
            imageData: article.imageData,
            name: article.title,
            description: article.descript,
            date: article.date,
            source: article.author,
            link: article.url))
        
        articleDetailsView.delegate = self
    }
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        articleDetailsView.frame = view.bounds
    }
    
    func articleDetailsViewDidTapLinkButton(_ view: ArticleDetailsView) {
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        let vc = WebViewViewController(url: url, title: article.title ?? "")
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
