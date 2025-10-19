import Foundation
import UIKit

class DownloadPhotoOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Photos"
        queue.maxConcurrentOperationCount = maxConcurrentOperationCount
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    private let maxConcurrentOperationCount: Int
    
    init(maxConcurrentOperationCount: Int = ProcessInfo.processInfo.processorCount) {
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    func addOperation(_ operation: Operation) {
        downloadQueue.addOperation(operation)
    }

    func cancelAllDownloads() {
        downloadQueue.cancelAllOperations()
        downloadsInProgress.removeAll()
    }
}

class ImageDownloader: Operation, @unchecked Sendable {
    private var task: URLSessionDataTask?
    private let url: URL
    
    private(set) var image: UIImage?
    private(set) var error: Error?
    
    private var _isFinished = false
    private var _isExecuting = false
    
    override var isAsynchronous: Bool { true }
    
    override private(set) var isExecuting: Bool {
        get { _isExecuting }
        set {
            willChangeValue(forKey: "isExecuting");
            _isExecuting = newValue;
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override private(set) var isFinished: Bool {
        get { _isFinished }
        set {
            willChangeValue(forKey: "isFinished");
            _isFinished = newValue;
            didChangeValue(forKey: "isFinished")
        }
    }
    
    init(url: URL) {
        self.url = url
    }
    
    override func start() {
        if isCancelled {
            finish()
            return
        }
        
        isExecuting = true
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, err in
            guard let self = self else { return }
            defer { self.finish() }
            
            if self.isCancelled { return }
            
            if let err = err {
                self.error = err
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                self.error = NSError(
                    domain: "ImageDownloadError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid or empty image data"]
                )
                return
            }
            
            self.image = image
        }
        
        task?.resume()
    }
    
    override func cancel() {
        super.cancel()
        task?.cancel()
    }
    
    private func finish() {
        isExecuting = false
        isFinished = true
    }
}
