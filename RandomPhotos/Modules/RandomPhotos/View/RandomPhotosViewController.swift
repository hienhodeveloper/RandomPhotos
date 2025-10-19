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
    func reloadCellAtIndexPath(indexPath: IndexPath)
    func scrollToFirstItem()
    func scrollToLastItem()
}

class RandomPhotosViewController: UIViewController, RandomPhotosViewProtocol {
    private lazy var presenter: RandomPhotosPresenter = RandomPhotosPresenter(view: self)
    private let spacing: CGFloat = 2
    private let columns = 7
    private let rows = 10
    private let reuseId = "PhotoCell"
    
    private lazy var collectionView: UICollectionView = {
        let layout = PaginationLayout(columns: columns, rows: rows, spacing: spacing)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
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
        let totalSpacingY = CGFloat(rows - 1) * spacing
        let totalSpacingX = CGFloat(columns - 1) * spacing
        
        let itemWidth = (view.bounds.width - totalSpacingX) / CGFloat(columns)
        let collectionViewHeight = itemWidth * CGFloat(rows) + totalSpacingY
            
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(collectionViewHeight)
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
}

// MARK: - UICollectionViewDataSource
extension RandomPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsPerPage = columns * rows
        let numberOfPages = Int(ceil(Double(presenter.photos.count) / Double(itemsPerPage)))
        return numberOfPages * itemsPerPage
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
            emptyPhoto.state = .empty
            cell.setup(photoRecord: emptyPhoto)
        }
        
        return cell
    }
}
