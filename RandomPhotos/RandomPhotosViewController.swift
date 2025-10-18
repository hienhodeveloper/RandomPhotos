//
//  ViewController.swift
//  RandomPhotos
//
//  Created by Ho Hien on 18/10/25.
//

import UIKit
import SnapKit

class RandomPhotosViewController: UIViewController {
    
    // MARK: - Properties
    private let spacing: CGFloat = 2
    private let columns = 7
    private let rows = 10
    private let reuseId = "PhotoCell"
    
    private var photos: [PhotoRecord] = []
    private let downloadOperations = DownloadOperations()
    
    private lazy var collectionView: UICollectionView = {
        let layout = PaginationLayout(columns: columns, rows: rows, spacing: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        view.backgroundColor = .white // Added white background for main view
        setupNavigationBar()
        setupCollectionView()
        
        // Load 140 random image URLs
        for _ in 0..<140 {
            if let url = URL(string: "https://picsum.photos/200/200") {
                photos.append(PhotoRecord(url: url))
            }
        }

        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let reloadButton = UIBarButtonItem(title: "Reload All", style: .plain, target: self, action: #selector(reloadButtonTapped))
        navigationItem.rightBarButtonItems = [addButton, reloadButton]
    }

    private func scrollToLastItem() {
        let lastItemIndexPath = IndexPath(item: photos.count - 1, section: 0)
        collectionView.scrollToItem(at: lastItemIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func addButtonTapped() {
        if let url = URL(string: "https://picsum.photos/200/200") {
            photos.append(PhotoRecord(url: url))
            collectionView.reloadData()
        }
        scrollToLastItem()
    }
    
    @objc private func reloadButtonTapped() {
        photos.removeAll()
        for _ in 0..<140 {
            if let url = URL(string: "https://picsum.photos/200/200") {
                photos.append(PhotoRecord(url: url))
            }
        }
        collectionView.reloadData()
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
    
}

// MARK: - UICollectionViewDataSource
extension RandomPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsPerPage = columns * rows
        let numberOfPages = Int(ceil(Double(photos.count) / Double(itemsPerPage)))
        return numberOfPages * itemsPerPage
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        // Nếu item index vượt quá số lượng photos, hiển thị empty cell
        if indexPath.item < photos.count {
            cell.setup(photoRecord: photos[indexPath.item])
        } else {
            // Tạo empty PhotoRecord để hiển thị cell rỗng
            let emptyPhoto = PhotoRecord(url: URL(string: "about:blank")!)
            emptyPhoto.state = .empty
            cell.setup(photoRecord: emptyPhoto)
        }
        
        return cell
    }
}
