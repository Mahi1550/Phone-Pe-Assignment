//
//  QuizService.swift
//  Logo Finder
//
//  Created by mahenderg on 10/04/21.
//

import Foundation

typealias CompletionResult = (Data?, HTTPURLResponse?, Error?) -> Void

protocol QuizServiceProtocol {
    func requestData<T: Codable>(model: T.Type,
                             completionHandler: @escaping (T?, HTTPURLResponse?, Error?) -> Void)
    func downloadImage(from link: String, completion: @escaping CompletionResult)
}

class QuizService: QuizServiceProtocol {
    static let shared = QuizService(session: URLSession.shared)
    private let session: URLSession

    private init(session: URLSession) {
        self.session = session
    }
    
    func requestData<T: Codable>(model: T.Type,
                             completionHandler: @escaping (T?, HTTPURLResponse?, Error?) -> Void) {
        
        let data = getData(name: "logo")
        let urlResponse = HTTPURLResponse(url: URL(string: "logo.txt")!, statusCode: 200, httpVersion: "2.0", headerFields: nil)
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            completionHandler(result, urlResponse, nil)
        } catch let error {
            completionHandler(nil, nil, error)
        }
    }
    
    func downloadImage(from link: String, completion: @escaping CompletionResult) {
        guard let url = URL(string: link) else { return }
        let task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.sync {
                completion(data, response as? HTTPURLResponse, error)
            }
        }
        task.resume()
    }

    private func getData(name: String, withExtension: String = "txt") -> Data {
        let bundle = Bundle(for: type(of: self))
        let fileUrl = bundle.url(forResource: name, withExtension: withExtension)
        let data = try! Data(contentsOf: fileUrl!)
        return data
    }
}
