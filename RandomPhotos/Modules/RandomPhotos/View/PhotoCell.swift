//
//  PhotoCell.swift
//  RandomPhotos
//
//  Created by Ho Hien on 18/10/25.
//

import UIKit
import SnapKit

enum PhotoRecordState {
    case new, downloading, success, failed, blank
}

class PhotoRecord {
    let url: URL
    var state = PhotoRecordState.new
    var image: UIImage?
    
    init(url:URL) {
        self.url = url
    }
}

class PhotoCell: UICollectionViewCell {
    private var photoRecord: PhotoRecord?
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let retryButton = UIButton()
    private var onRetryTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(retryButton)
                
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        retryButton.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        retryButton.tintColor = .systemRed
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
    }
    
    @objc private func retryTapped() {
        onRetryTapped?()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        retryButton.isHidden = true
        activityIndicator.stopAnimating()
        onRetryTapped = nil
        super.prepareForReuse()
    }
    
    func setup(photoRecord: PhotoRecord, onRetryTapped: (() -> Void)? = nil) {
        self.photoRecord = photoRecord
        self.onRetryTapped = onRetryTapped
        
        retryButton.isHidden = true
        imageView.image = nil
        activityIndicator.stopAnimating()
        contentView.backgroundColor = nil

        switch photoRecord.state {
        case .downloading, .new:
            activityIndicator.startAnimating()
        case .success:
            imageView.image = photoRecord.image
            
        case .failed:
            retryButton.isHidden = false
            
        case .blank:
            contentView.backgroundColor = .clear
        }
    }
}
