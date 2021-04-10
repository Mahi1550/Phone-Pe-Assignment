//
//  ViewController.swift
//  Logo Finder
//
//  Created by mahenderg on 10/04/21.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userEnteredNameView: TagListView!
    @IBOutlet weak var OptionsToChooseView: TagListView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var quizViewModel: QuizViewModelProtocol!
    
    required init?(coder: NSCoder) {
        self.quizViewModel = QuizViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTagView()
        activityIndicator.startAnimating()
        quizViewModel.getLogos {[weak self] (error) in
            self?.activityIndicator.stopAnimating()
            if error != nil {
                self?.showAlert(Constants.ErrorMsges.logoDataFailure, from: self, completion: nil)
            } else {
                self?.loadLogo()
            }
        }
    }

    private func setupTagView() {
        userEnteredNameView.textFont = UIFont.systemFont(ofSize: 36)
        userEnteredNameView.alignment = .center
        OptionsToChooseView.textFont = UIFont.systemFont(ofSize: 24)
        OptionsToChooseView.alignment = .center
    }
    
    @IBAction func nextLogo(_ sender: Any) {
        loadLogo()
    }
    
    private func loadLogo() {
        activityIndicator.startAnimating()
        let logo = quizViewModel.nextLogo
        guard let nextLogo = logo else {
            return
        }
        loadOptionsToSelect(name: nextLogo.name)
        quizViewModel.getImage(with: nextLogo.imgUrl) { (data, error) in
            self.activityIndicator.stopAnimating()
            if let imageData = data {
                self.logoImageView.image = UIImage(data: imageData)
            } else {
                self.showAlert(Constants.ErrorMsges.loadImageFailure, from: self, completion: nil)
            }
        }
    }
    
    private func loadOptionsToSelect(name: String) {
        userEnteredNameView.removeAllTags()
        OptionsToChooseView.removeAllTags()
        let tags = quizViewModel.getOptionsToSelect(logoName: name);
        OptionsToChooseView.addTags(tags)
    }
    
    func showAlert(_ message: String, from viewController: UIViewController?, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Logo Finder", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: completion))
        viewController?.present(alert, animated: true, completion: nil)
    }
}

extension QuizViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if userEnteredNameView.tagViews.count > 7 {
            userEnteredNameView.removeAllTags()
        }
        userEnteredNameView.addTag(title)
        var name = ""
        for tagView in userEnteredNameView.tagViews {
            name += tagView.currentTitle!
        }
        if quizViewModel.currentLogo.name == name {
            showAlert(Constants.SuccessMsges.nameMatched, from: self) { (action) in
                self.loadLogo()
            }
        }
    }
}

