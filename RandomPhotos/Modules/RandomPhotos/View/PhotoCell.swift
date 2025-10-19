//
//  PhotoCell.swift
//  RandomPhotos
//
//  Created by Ho Hien on 18/10/25.
//

import UIKit
import SnapKit

enum PhotoRecordState {
    case new, downloading, success, failed, empty
}

class PhotoRecord {
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    init(url:URL) {
        self.url = url
    }
}

class PhotoCell: UICollectionViewCell {
    private var photoRecord: PhotoRecord?
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let failedImageView = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
    
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
        contentView.addSubview(failedImageView)
                
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        failedImageView.isHidden = true
        failedImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(16)
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        failedImageView.isHidden = true
        activityIndicator.stopAnimating()
        super.prepareForReuse()
    }
    
    func setup(photoRecord: PhotoRecord) {
        failedImageView.isHidden = true
        self.photoRecord = photoRecord
        
        if photoRecord.state == .downloading || photoRecord.state == .new {
            activityIndicator.startAnimating()
        } else if photoRecord.state == .success {
            activityIndicator.stopAnimating()
            imageView.image = photoRecord.image
        } else if photoRecord.state == .failed {
            activityIndicator.stopAnimating()
            failedImageView.isHidden = false
        } else if photoRecord.state == .empty {
            activityIndicator.stopAnimating()
            imageView.image = nil
            contentView.backgroundColor = .clear
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
