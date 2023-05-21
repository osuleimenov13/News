//
//  TopHeadlinesNewsResponse.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 03.02.2023.
//

import Foundation

struct TopHeadlinesNewsResponse: Codable {
    let totalResults: Int?
    let articles: [ArticleResponse]?
}


struct ArticleResponse: Codable {
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}
