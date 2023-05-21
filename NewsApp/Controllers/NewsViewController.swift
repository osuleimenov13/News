//
//  ViewController.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 03.02.2023.
//

import UIKit
import CoreData

class NewsViewController: UIViewController {
    
    // reference to managed object context (although better to create separate class for CoreData business)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    private var articles = [Article]()
    
    private var totalNews: Int?
    private var isFetchingMoreNews = false
    private var page = 2
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.isHidden = false
        return tableView
    }()
    
    private let noNewsView = NoNewsView()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "News"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(tableView)
        view.addSubview(noNewsView)
        view.addSubview(spinner)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        fetchNewsFromCoreData()
        
        if articles.isEmpty {
            noNewsView.isHidden = false
            fetchNews()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNewsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noNewsView.center = view.center
        spinner.frame = CGRect(x: (view.width-20)/2, y: noNewsView.bottom, width: 20, height: 20)
    }
    
    /// Fetch initial set of news (20)
    private func fetchNews() {
        // check for internet connection
        guard NetworkMonitor.shared.isConnected else {
            showNoInternetAlert()
            return
        }
        
        spinner.startAnimating()
        APICaller.shared.getNewsForTopHeadlines { [weak self] result in
            switch result {
            case .success(let result):
                guard let articles = result.articles, let context = self?.context else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.deleteNewsFromCoreData()
                }
                
                self?.articles = articles.compactMap({
                    let newArticle = Article(context: context)
                    newArticle.title = $0.title
                    newArticle.descript = $0.description
                    newArticle.author = $0.author
                    newArticle.url = $0.url
                    newArticle.date = $0.publishedAt
                    newArticle.viewsCount = 0
                    if let url = URL(string: $0.urlToImage ?? "") {
                        newArticle.imageData = try? Data(contentsOf: url)
                    }
                    return newArticle
                })
                
                self?.saveNewsToCoreData()
                self?.fetchNewsFromCoreData()
                
                
                DispatchQueue.main.async {
                    self?.noNewsView.isHidden = true
                    self?.spinner.stopAnimating()
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                }
                self?.totalNews = result.totalResults
            case .failure(_):
                self?.spinner.stopAnimating()
            }
        }
    }
    
    /// Fetch additional news (20)
    private func fetchAdditionalNews() {
        // check for internet connection
        guard NetworkMonitor.shared.isConnected else {
            showNoInternetAlert()
            return
        }
        
        isFetchingMoreNews = true
        APICaller.shared.getNewsForTopHeadlines(page: page) { [weak self] result in
            switch result {
            case .success(let result):
                guard let articles = result.articles, let context = self?.context else {
                    return
                }
                
                self?.articles.append(contentsOf: articles.compactMap({
                    let newArticle = Article(context: context)
                    newArticle.title = $0.title
                    newArticle.descript = $0.description
                    newArticle.author = $0.author
                    newArticle.url = $0.url
                    newArticle.date = $0.publishedAt
                    newArticle.viewsCount = 0
                    if let url = URL(string: $0.urlToImage ?? "") {
                        newArticle.imageData = try? Data(contentsOf: url)
                    }
                    
                    return newArticle
                }))
                
                self?.saveNewsToCoreData()
                self?.fetchNewsFromCoreData()
                
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                    self?.tableView.reloadData()
                }
                self?.totalNews = result.totalResults
                self?.page += 1
                self?.isFetchingMoreNews = false
            case .failure(_):
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                }
                self?.isFetchingMoreNews = false
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        // Refetch the data, tried to fetch additional news here but app crashes or conflicts with scrollViewDidScroll unfortunately no time to fix so just mock refreshing indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func fetchNewsFromCoreData() {
        do {
            articles = try context.fetch(Article.fetchRequest())
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func saveNewsToCoreData() {
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    private func deleteNewsFromCoreData() {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Article.fetchRequest())
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        }
        catch {
            
        }
        articles.removeAll()
    }
    
    private func showNoInternetAlert() {
        let ac = UIAlertController(title: "No Connection", message: "Oops... it seems you not connected to internet", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}


extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let model = articles[indexPath.row]
        cell.configure(with: NewsTableViewCellViewModel(imageData: model.imageData,
                                                        title: model.title,
                                                        viewsCount: "Views: \(model.viewsCount)"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        article.viewsCount += 1
        saveNewsToCoreData()
        tableView.reloadData()
        let vc = ArticleDetailsViewController(article: article)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


extension NewsViewController: UIScrollViewDelegate {
    
    // to check if there more news available to load if not - not try at all
    private var shouldShowLoadMoreIndicator: Bool {
        if let totalNews = totalNews, articles.count < totalNews {
            return true
        }
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator, !isFetchingMoreNews else {
            return
        }

        let offset = scrollView.contentOffset.y
        let totalContentHeight = tableView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.height

        if offset >= (totalContentHeight - totalScrollViewFixedHeight + 40) {
            print("will start fetching more news")
            tableView.tableFooterView = createSpinnerFooter()
            fetchAdditionalNews()
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}

