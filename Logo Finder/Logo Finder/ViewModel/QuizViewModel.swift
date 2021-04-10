//
//  QuizViewModel.swift
//  Logo Finder
//
//  Created by mahenderg on 10/04/21.
//

import Foundation
import UIKit

protocol QuizViewModelProtocol {
    var nextLogo: Logo? { get }
    var currentLogo: Logo { get }
    
    func getLogos(completion: ((Error?) -> Void)?)
    func getImage(with url: String, completion: ((Data?, Error?) -> Void)?)
    func getOptionsToSelect(logoName: String) -> [String]
}

class QuizViewModel: QuizViewModelProtocol {
    private var quizService: QuizServiceProtocol
    private var logos: [Logo] = []
    private var currentLogoIndex = 0

    init(service: QuizServiceProtocol = QuizService.shared) {
        quizService = service
    }
    
    var nextLogo: Logo? {
        if currentLogoIndex >= self.logos.count {
            currentLogoIndex = 0
            return self.logos[currentLogoIndex]
        } else {
            let nextLogo = self.logos[currentLogoIndex]
            currentLogoIndex += 1
            return nextLogo
        }
    }
    
    var currentLogo: Logo {
        return logos[currentLogoIndex-1]
    }
    
    func getLogos(completion: ((Error?) -> Void)?) {
        quizService.requestData(model: [Logo].self) { [weak self] (logosResult, response, error) in
            if let logos = logosResult {
                self?.logos = logos
                completion?(nil)
            } else {
                completion?(error)
            }
        }
    }
    
    func getImage(with url: String, completion: ((Data?, Error?) -> Void)?) {
        quizService.downloadImage(from: url) { (data, response, error) in
            if let imageData = data {
                completion?(imageData, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
    
    func getOptionsToSelect(logoName: String) -> [String] {
        var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let answerLength = logoName.count
        for _ in 0 ..< (answerLength + 6) {
            let index = letters.firstIndex(of: letters.randomElement()!)!
            letters.remove(at: index)
        }
        letters.append(logoName)
        var options = ""
        for _ in 0 ..< 20 {
            let randomElement = letters.randomElement()!
            options.append(randomElement)
            let index = letters.firstIndex(of: randomElement)!
            letters.remove(at: index)
        }
        print(options)
        return  options.map { String($0) }
    }
}
