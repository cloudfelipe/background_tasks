//
//  BackgroundDownloader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloader: NSObject {
    
    var maxAtteptsByTask = 3
    var backgroundCompletionHandler: (() -> Void)?
    static let shared = BackgroundDownloader()
    private var session: URLSession!
    private let context = BackgroundDownloaderContext<BackgroundItem>()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "Background.Downloader.Session")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        restartPendingTasks()
    }
    
    func download(remoteURL: URL, filePathURL: URL, completionHandler: @escaping ForegroundCompletionHandler) {
        if let downloadItem = context.loadItem(withURL: remoteURL) {
            print("Already downloading: \(remoteURL)")
            downloadItem.completionHandler = completionHandler
            restartPendingTasks()
        } else {
            print("Scheduling to download: \(remoteURL)")
            let downloadItem = BackgroundItem(id: UUID().uuidString, remotePathURL: remoteURL, localPathURL: filePathURL)
            downloadItem.completionHandler = completionHandler
            startDownloadigItem(downloadItem)
        }
    }
    
    private func startDownloadigItem(_ item: BackgroundItem) {
        item.newAttempt()
        if item.attempts > maxAtteptsByTask {
            context.deleteBackgroundItem(item)
            let error = NSError(domain: "Max attempts reached", code: 500, userInfo: nil)
            item.completionHandler?(.failure(error))
            return
        }
        context.saveBackgroundItem(item)
        let task = session.downloadTask(with: item.remotePathURL)
        task.earliestBeginDate = Date().addingTimeInterval(5)
        task.resume()
    }
    
    func restartPendingTasks() {
        session.getTasksWithCompletionHandler { [weak self] (_, uploadTasks, downloadTasks) in
            guard let incompletedDownloadItems = self?.incompletedItems(excluding: downloadTasks) else { return }
            self?.startDownloadingItems(incompletedDownloadItems)
            print(("Upload tasks: \(uploadTasks.count)"),
                  ("Download tasks: \(downloadTasks.count)"),
                  separator: "\n", terminator: "\n")
        }
    }
}

extension BackgroundDownloader {
    private func startDownloadingItems(_ items: [BackgroundItem]) {
        items.forEach { startDownloadigItem($0) }
    }
    
    private func incompletedItems(excluding tasks: [URLSessionTask]) -> [BackgroundItem] {
        let currentDownloading = tasks.compactMap { $0.originalRequest?.url }
        return self.context.loadAllItemsFiltering(currentDownloading, exclude: true)
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
        NotificationManager.shared.sheduleNotificationInBackground(title: "urlSessionDidFinishEvents")
    }
}
