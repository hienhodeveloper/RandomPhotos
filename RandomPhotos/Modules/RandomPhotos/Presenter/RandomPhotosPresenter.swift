//
//  RandomPhotosPresenter.swift
//  RandomPhotos
//
//  Created by Ho Hien on 19/10/25.
//

import Foundation

class RandomPhotosPresenter {
    private let DEFAULT_RELOAD_ALL_COUNT = 140
    private let DEFAULT_RANDOM_PHOTO_URL = "https://picsum.photos/200/200"
    
    private let view: RandomPhotosViewProtocol
    private(set) var photos: [PhotoRecord] = []
    private(set) var downloadOperations = DownloadOperations()
    
    init(view: RandomPhotosViewProtocol) {
        self.view = view
    }
    
    func addAPhoto() {
        guard let url = URL(string: DEFAULT_RANDOM_PHOTO_URL) else { return }
        let photoRecord = PhotoRecord(url: url)
        photos.append(photoRecord)
        view.reloadPhotos()
        let indexPath = IndexPath(item: photos.count - 1, section: 0)
        startDownload(for: photoRecord, at: indexPath)
        view.scrollToLastItem()
    }
    
    func reloadAll() {
        clearAllDownloads()
        guard let url = URL(string: DEFAULT_RANDOM_PHOTO_URL) else { return }
        photos = []
        for _ in 0..<DEFAULT_RELOAD_ALL_COUNT {
            photos.append(PhotoRecord(url: url))
        }
        view.reloadPhotos()
        view.scrollToFirstItem()
        startDownloadPhotos(for: photos)
    }
    
    private func startDownloadPhotos(for photoRecords: [PhotoRecord]) {
        for (index, photoRecord) in photoRecords.enumerated() {
            startDownload(for: photoRecord, at: IndexPath(item: index, section: 0))
        }
    }
    
    private func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard downloadOperations.downloadsInProgress[indexPath] == nil else { return }
        
        let downloader = ImageDownloader(url: photoRecord.url)
        downloader.completionBlock = { [weak self] in
            guard let self = self else { return }
            if downloader.isCancelled { return }
            let resultImage = downloader.image
            let _ = downloader.error
            if (resultImage != nil) {
                photoRecord.image = resultImage
                photoRecord.state = .success
            } else {
                photoRecord.state = .failed
            }
            self.downloadOperations.downloadsInProgress.removeValue(forKey: indexPath)
            DispatchQueue.main.async {
                self.view.reloadCellAtIndexPath(indexPath: indexPath)
            }
        }
        
        downloadOperations.downloadsInProgress[indexPath] = downloader
        downloadOperations.addOperation(downloader)
    }
    
    private func clearAllDownloads() {
        photos.removeAll()
        downloadOperations.cancelAllDownloads()
    }
}
