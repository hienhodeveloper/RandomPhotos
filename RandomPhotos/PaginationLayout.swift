//
//  PaginationLayout.swift
//  RandomPhotos
//
//  Created by Ho Hien on 18/10/25.
//

import UIKit

class PaginationLayout: UICollectionViewLayout {
    
    private let spacing: CGFloat
    private let columns: Int
    private let rows: Int
    private let itemsPerPage: Int
    private let horizontalPadding: CGFloat
    
    private var itemSize: CGSize = .zero
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    init(columns: Int, rows: Int, spacing: CGFloat) {
        self.columns = columns
        self.rows = rows
        self.spacing = spacing
        self.itemsPerPage = columns * rows
        self.horizontalPadding = spacing / 2
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let totalSpacingX = CGFloat(columns - 1) * spacing
        let availableWidth = collectionView.bounds.width - (horizontalPadding * 2) // Left and right padding
        let itemWidth = (availableWidth - totalSpacingX) / CGFloat(columns)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        layoutAttributes.removeAll()
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let pageIndex = item / itemsPerPage
            let itemIndexInPage = item % itemsPerPage
            
            let row = itemIndexInPage / columns
            let column = itemIndexInPage % columns
            
            let x = CGFloat(pageIndex) * collectionView.bounds.width + horizontalPadding + CGFloat(column) * (itemSize.width + spacing)
            let y = CGFloat(row) * (itemSize.height + spacing)
            
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
            layoutAttributes.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        return CGSize(
            width: CGFloat(numberOfPages) * collectionView.bounds.width,
            height: collectionView.bounds.height
        )
    }
    
     override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
         return layoutAttributes.filter { $0.frame.intersects(rect) }
     }
    
     override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
         return layoutAttributes.first { $0.indexPath == indexPath }
     }
    
     override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
         return newBounds.width != collectionView?.bounds.width
     }
}
