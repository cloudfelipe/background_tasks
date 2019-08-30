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
            let downloadItem = BackgroundItem(id: UUID().uuidString, remotePathURL: remoteURL, localPathURL: filePathURL)
            downloadItem.completionHandler = completionHandler
            context.saveBackgroundItem(downloadItem)
            downloadItem.completed = true
            let task = session.downloadTask(with: remoteURL)
            task.earliestBeginDate = Date().addingTimeInterval(10)
            task.resume()
        }
    }
}

extension BackgroundDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let userDe = UserDefaults.standard
        let previous1 = userDe.value(forKey: "pre-didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous1+1, forKey: "pre-didFinishDownloadingTo")
        
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
        
        let previous = userDe.value(forKey: "didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous+1, forKey: "didFinishDownloadingTo")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let userDe = UserDefaults.standard
        let previous = userDe.value(forKey: "urlSessionDidFinishEvents") as? Int ?? 0
        userDe.set(previous+1, forKey: "urlSessionDidFinishEvents")
        userDe.synchronize()
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
