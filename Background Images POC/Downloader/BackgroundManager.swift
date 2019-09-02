//
//  BackgroundManager.swift
//  Background Images POC
//
//  Created by Felipe Correa on 9/2/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundManager<T: BackgroundItemType>: NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
    var backgroundCompletionHandler: (() -> Void)?
    
    internal var session: URLSession!
    internal let context = BackgroundDownloaderContext<T>()
    private var maxAtteptsByTask = 3
    
    internal override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "Background.Downloader.Session")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func startTask(_ item: T) {
        item.newAttempt()
        if item.attempts > maxAtteptsByTask {
            context.deleteBackgroundItem(item)
            let error = NSError(domain: "Max attempts reached", code: 500, userInfo: nil)
            item.completionHandler?(.failure(error))
            return
        }
        item.setStatus(.running)
        context.saveBackgroundItem(item)
        executeTask(item)
    }
    
    func executeTask(_ taks: T) { }
    
    private func recoveryTaskForm(_ originUrl: URL?) -> T? {
        guard let url = originUrl, let backgroundTask = context.loadItem(withURL: url) else {
            debugPrint("Didn't able to recover the background task for: \(originUrl?.absoluteString ?? "undefined")")
            return nil
        }
        return backgroundTask
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("ERORR UPLOADING: \(error)")
            let backgroundTask = recoveryTaskForm(task.currentRequest?.url)
            backgroundTask?.completionHandler?(.failure(error))
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let backgroundTask = recoveryTaskForm(dataTask.currentRequest?.url) else {
            return
        }
        print("Completed uploading task to \(backgroundTask.remotePathURL.absoluteString)")
        backgroundTask.setStatus(.completed)
        context.saveBackgroundItem(backgroundTask)
        backgroundTask.completionHandler?(.success(backgroundTask))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let userDe = UserDefaults.standard
        let previous1 = userDe.value(forKey: "pre-didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous1+1, forKey: "pre-didFinishDownloadingTo")
        
        guard let downloadItem = recoveryTaskForm(downloadTask.currentRequest?.url) else {
            return
        }
        print("Downloaded: \(downloadItem.remotePathURL)")
        do {
            try FileManager.default.moveItem(at: location, to: downloadItem.localPathURL)
            //            downloadItem.completionHandler?(.success(downloadItem.localPathURL))
        } catch let error {
            downloadItem.completionHandler?(.failure(error))
        }
        
        context.deleteBackgroundItem(downloadItem)
        
        let previous = userDe.value(forKey: "didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous+1, forKey: "didFinishDownloadingTo")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
            print("completed background task")
        }
        NotificationManager.shared.sheduleNotificationInBackground(title: "urlSessionDidFinishEvents")
    }
}
