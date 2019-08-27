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
    
    private let context = BackgroundDownloaderContext()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "Background.Downloader.Session")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func download(remoteURL: URL, filePathURL: URL, completionHandler: @escaping ForegroundDownloadCompletionHandler) {
        if let downloadItem = context.loadDownloadItem(withURL: remoteURL) {
            print("Already downloading: \(remoteURL)")
            downloadItem.foregroundCompletionHandler = completionHandler
        } else {
            print("Scheduling to download: \(remoteURL)")
            let downloadItem = DownloadItem(remoteURL: remoteURL, filePathURL: filePathURL)
            downloadItem.foregroundCompletionHandler = completionHandler
            context.saveDownloadItem(downloadItem)
            
            let task = session.downloadTask(with: remoteURL)
            task.earliestBeginDate = Date().addingTimeInterval(5)
            task.resume()
        }
    }
}

extension BackgroundDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalRequestURL = downloadTask.originalRequest?.url,
            let downloadItem = context.loadDownloadItem(withURL: originalRequestURL) else {
                return
        }
        print("Downloaded: \(downloadItem.remoteURL)")
        do {
            try FileManager.default.moveItem(at: location, to: downloadItem.filePathURL)
            downloadItem.foregroundCompletionHandler?(.success(downloadItem.filePathURL))
        } catch let error {
            downloadItem.foregroundCompletionHandler?(.failure(error))
        }
        
        context.deleteDownloadItem(downloadItem)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
