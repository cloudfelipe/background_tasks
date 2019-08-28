//
//  BackgroundDownloader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloader: NSObject {
    
    private var session: URLSession!
    static let shared = BackgroundDownloader()
    var backgroundCompletionHandler: (() -> Void)?
    
    private let context = BackgroundDownloaderContext<BackgroundItem>()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "Background.Downloader.Session")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func download(remoteURL: URL, filePathURL: URL, completionHandler: @escaping ForegroundCompletionHandler) {
        if let downloadItem = context.loadItem(withURL: remoteURL) {
            print("Already downloading: \(remoteURL)")
            downloadItem.completionHandler = completionHandler
        } else {
            print("Scheduling to download: \(remoteURL)")
            let downloadItem = BackgroundItem(remotePathURL: remoteURL, localPathURL: filePathURL)
            downloadItem.completionHandler = completionHandler
            context.saveBackgroundItem(downloadItem)
            
            let task = session.downloadTask(with: remoteURL)
            task.earliestBeginDate = Date().addingTimeInterval(5)
            task.resume()
        }
    }
}

extension BackgroundDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url,
            let downloadItem = context.loadItem(withURL: originalRequestURL) else {
                return
        }
        print("Downloaded: \(downloadItem.remotePathURL)")
        do {
            try FileManager.default.moveItem(at: location, to: downloadItem.localPathURL)
            downloadItem.completionHandler?(.success(downloadItem.localPathURL))
        } catch let error {
            downloadItem.completionHandler?(.failure(error))
        }
        
        context.deleteBackgroundItem(downloadItem)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
