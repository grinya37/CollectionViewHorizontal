//
//  ViewController.swift
//  CollectionViewHorizontal
//
//  Created by Николай Гринько on 16.05.2023.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    private enum Section {
        case profile
        case stories
        case posts
        
        var numberOfItems: Int {
            switch self {
            case .stories:
                return 9
            case .posts:
                return 10
            case .profile:
                return 1
            }
        }
    }

    private lazy var layout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let sectionType = self.viewModel[section]
            
            switch sectionType {
                
            case .profile:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(300.0)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    // origin - subItem
                    repeatingSubitem: item,
                    count: sectionType.numberOfItems
                )
                let section = NSCollectionLayoutSection(group: group)
                section.supplementariesFollowContentInsets = false
                
                return section
                
            case .stories:
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(74.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupWidth = 74 * sectionType.numberOfItems + 8 * (sectionType.numberOfItems - 1)
                + 16 * 2
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(CGFloat(groupWidth)),
                    heightDimension: .absolute(90)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    //origin - subitem
                    subitem: item,
                    count: sectionType.numberOfItems
                )
                group.interItemSpacing = .fixed(8)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 0,
                    trailing: 16
                )
                
                section.visibleItemsInvalidationHandler = { (_, scrollOffset, _) in
                    self.scrollXOffset = scrollOffset.x
                }
                section.orthogonalScrollingBehavior = .continuous
                section.supplementariesFollowContentInsets = false
                return section
            case .posts:
                let numberOfItemsInRow: CGFloat = 3.0
                let contentsize = environment.container.contentSize
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupHeight = (contentsize.width - numberOfItemsInRow * 2) / numberOfItemsInRow
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(groupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: item,
                    count: Int(numberOfItemsInRow)
                )
                group.interItemSpacing = .fixed(2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 2
                section.supplementariesFollowContentInsets = false
                
                return section
            }
        }
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StoryCell.self, forCellWithReuseIdentifier: "StoryCellID")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCellID")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let viewModel: [Section] = [
        .profile,
        .stories,
        .posts
    ]
    
    private var selectedStoryCell: StoryCell?
    private var selectedCellSnapshot: UIView?
    private var animator: CircularAnimator?
    private var watchedCellIndexes: Set<IndexPath> = Set()
    
    private var startingAnimationPoint: CGPoint {
        guard let cellCenterPoint = self.selectedStoryCell?.center,
              let navigationBarHeight = self.navigationController?.navigationBar.frame.height,
              let navigationBarYOffset = self.navigationController?.navigationBar.frame.origin.y
        else { return .zero }
     
        return CGPoint(
            
            x: cellCenterPoint.x,
            y: cellCenterPoint.y + navigationBarHeight + navigationBarYOffset
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupview()
       
    }
    private func setupview() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
        ])
    }
}

extension ViewController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel[section].numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = self.viewModel[indexPath.section]
        switch sectionType {
        case .profile:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCellID", for: indexPath
            )
            
            // color верхней ячейки
            cell.backgroundColor = .red
            return cell
            
        case .stories:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "StoryCellID", for: indexPath
            ) as? StoryCell else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCellID", for: indexPath)
            }
            cell.setup(hasBeenWatched: self.watchedCellIndexes.contains(indexPath))
            return cell
        case .posts:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCellID", for: indexPath
            )
            cell.backgroundColor = .red
            return cell
        
        }
    }
    }
    
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedStoryCell = collectionView.cellForItem(at: indexPath) as? StoryCell
        self.selectedCellSnapshot = self.selectedStoryCell?.container.snapshotView(afterScreenUpdates: false)
        
        self.watchedCellIndexes.insert(indexPath)
        
        let storyViewController = StoryViewController()
        storyViewController.delegate = self
        
        // Применима для кложура
//        storyViewController.closure = {
//            self.selectedStoryCell?.storyHasBeenVatched()
//        }
        storyViewController.modalPresentationStyle = .custom
        storyViewController.transitioningDelegate = self
        self.present(storyViewController, animated: true)
    }
    
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator = CircularAnimator(
            duration: 1.0,
            circleColor: presented.view.backgroundColor ?? .systemBackground,
            selectedCellSnapshot: self.selectedCellSnapshot
        )
        return self.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator?.setup(usingTransitionMode: .dismiss,
                             andStartingPoint: self.startingAnimationPoint
        )
        return self.animator
    }
    
}

// MARK: Рвсштрение для протокола делегата

extension ViewController: StoryViewControllerDelegate {
    func storyHasBeenWatched() {
        self.selectedStoryCell?.storyHasBeenWatched()
    }
    
    
    
    
    
    
    
    //MARK: Conteiner View Prewiews
    struct ContentViewPreviews: PreviewProvider {
        
        struct Container: UIViewControllerRepresentable {
            func makeUIViewController(context: Context) -> some UIViewController {
                UINavigationController(rootViewController: ViewController())
            }
            func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
            
        }
        static var previews: some View {
            Container().edgesIgnoringSafeArea(.all)
        }
    }
}
