//
//  StoryCell.swift
//  CollectionViewHorizontal
//
//  Created by Николай Гринько on 16.05.2023.
//

import UIKit

final class StoryCell: UICollectionViewCell {
    
    private lazy var containerView: UIView = {
       
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2
        self.containerView.layer.cornerRadius = (self.frame.width - 8) / 2
    }
    
    func setup(hasBeenWatched: Bool) {
        self.layer.borderWidth = hasBeenWatched ? 1 : 2
        self.layer.borderColor = hasBeenWatched
        ? UIColor.gray.cgColor
        :UIColor.red.cgColor
        if hasBeenWatched {
            self.alpha = 0.75
        }
    }
    
    func storyHasBeenWatched() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        self.alpha = 0.75
    }
    
    private func setupSelf() {
        self.backgroundColor = .clear
        
        self.addSubview(self.containerView)
        
        NSLayoutConstraint.activate([
        
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
            
            
        ])
    }
}
