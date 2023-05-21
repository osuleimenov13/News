//
//  APICaller.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 03.02.2023.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private init() {}
    
    enum APIError: Error {
        case failedToGetData
    }
    
    struct Constants {
        static let baseAPIURL = "https://newsapi.org/v2"
        static let topHeadlinesEndpoint = "/top-headlines?country=us"
        static let everythingEndpoint = "/everything"
        
        // restriction for 100 request per day so 2 keys just in case
        static let APIKey = "&apiKey=a4623e033c824bf89ff6fefc6cd856aa"
        static let APIKey2 = "&apiKey=d04e0ee6007c40d0aae2569e82673118"

    }
    
    // MARK: - Public

    public func getNewsForTopHeadlines(completion: @escaping (Result<TopHeadlinesNewsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + Constants.topHeadlinesEndpoint + "&pageSize=20" + Constants.APIKey2), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(TopHeadlinesNewsResponse.self, from: data)
                    completion(.success(result))
                    print("Got News: \(result)")
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getNewsForTopHeadlines(page: Int, completion: @escaping (Result<TopHeadlinesNewsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + Constants.topHeadlinesEndpoint + "&pageSize=20" + "&page=\(page)" + Constants.APIKey2), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(TopHeadlinesNewsResponse.self, from: data)
                    completion(.success(result))
                    print("Got additional News: \(result)")
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    private func createRequest(with url: URL?,
                               type: HTTPMethod,
                               completion: @escaping (URLRequest) -> Void) {
        guard let apiURL = url else {
            return
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = type.rawValue
        completion(request)
    }
}
