//
//  StoryViewController.swift
//  CollectionViewHorizontal
//
//  Created by Николай Гринько on 17.05.2023.
//

import UIKit

protocol StoryViewControllerDelegate: AnyObject {
    func storyHasBeenWatched()
}

final class StoryViewController: UIViewController {
    
   // var closure: (() -> Void)?
    weak var delegate: StoryViewControllerDelegate?
    
    private lazy var closeImageView: UIImageView = {
       
        let imageView = UIImageView(image: UIImage(systemName: "xmark.circle"))
        imageView.tintColor = .red
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.addGestures()
        view.backgroundColor = .yellow
    }
    
    private func setupView() {
        self.view.addSubview(self.closeImageView)
        
        NSLayoutConstraint.activate([
        
            self.closeImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.closeImageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.closeImageView.widthAnchor.constraint(equalToConstant: 40),
            self.closeImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addGestures() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        self.closeImageView.addGestureRecognizer(gesture)
        
    }
    @objc private func didTapImageView() {
       //Вызов кложура self.dismiss(animated: true, completion: self.closure)
        self.dismiss(animated: true) {
            self.delegate?.storyHasBeenWatched()
        }
    }
}
