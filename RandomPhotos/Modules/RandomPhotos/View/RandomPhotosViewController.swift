//
//  ViewController.swift
//  RandomPhotos
//
//  Created by Ho Hien on 18/10/25.
//

import UIKit
import SnapKit

protocol RandomPhotosViewProtocol: AnyObject {
    func reloadPhotos()
    func insertCellAtIndexPath(indexPath: IndexPath)
    func reloadCellAtIndexPath(indexPath: IndexPath)
    func scrollToFirstItem()
    func scrollToLastItem()
}

class RandomPhotosViewController: UIViewController, RandomPhotosViewProtocol {
    private lazy var presenter: RandomPhotosPresenter = RandomPhotosPresenter(view: self)
    private let spacing: CGFloat = 2
    private let columns = 7.0
    private let rows = 10.0
    private let reuseId = "PhotoCell"
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        view.backgroundColor = .white
        presenter.reloadAll()
        setupNavigationBar()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let reloadButton = UIBarButtonItem(title: "Reload All", style: .plain, target: self, action: #selector(reloadAllButtonTapped))
        navigationItem.rightBarButtonItems = [addButton, reloadButton]
    }

    @objc private func addButtonTapped() {
        presenter.addAPhoto()
    }
    
    @objc private func reloadAllButtonTapped() {
        presenter.reloadAll()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseId)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func updatePhotos(photos: [PhotoRecord]) {
        collectionView.reloadData()
    }

    func scrollToFirstItem() {
        guard !presenter.photos.isEmpty else { return }
        let firstItemIndexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: firstItemIndexPath, at: .centeredHorizontally, animated: true)
    }

    func scrollToLastItem() {
        guard !presenter.photos.isEmpty else { return }
        let lastItemIndexPath = IndexPath(item: presenter.photos.count - 1, section: 0)
        collectionView.scrollToItem(at: lastItemIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func reloadPhotos() {
        collectionView.reloadData()
    }
    
    func reloadCellAtIndexPath(indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }

    func insertCellAtIndexPath(indexPath: IndexPath) {
        if collectionView.numberOfItems(inSection: 0) > presenter.photos.count {
            collectionView.reloadItems(at: [indexPath])
            return
        }
        reloadPhotos()
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / columns),
            heightDimension: .fractionalWidth(1.0 / columns)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let rowGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / columns)
        )
        let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize, subitems: Array(repeating: item, count: Int(columns)))
        
        let pageGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(rows / columns)
        )
        let pageGroup = NSCollectionLayoutGroup.vertical(layoutSize: pageGroupSize, subitems: Array(repeating: rowGroup, count: Int(rows)))
        
        let section = NSCollectionLayoutSection(group: pageGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource
extension RandomPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    var numberOfItemsInSection: Int {
        let itemsPerPage = columns * rows
        let numberOfPages = Int(ceil(Double(presenter.photos.count) / Double(itemsPerPage)))
        return numberOfPages * Int(itemsPerPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.item < presenter.photos.count {
            cell.setup(photoRecord: presenter.photos[indexPath.item], onRetryTapped: { [weak self] in
                guard let self = self else { return }
                self.presenter.retryDownload(for: indexPath)
            })
        } else {
            let emptyPhoto = PhotoRecord(url: URL(string: "about:blank")!)
            emptyPhoto.state = .blank
            cell.setup(photoRecord: emptyPhoto)
        }
        
        return cell
    }
}
