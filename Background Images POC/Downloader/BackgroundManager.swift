//
//  BackgroundManager.swift
//  Background Images POC
//
//  Created by Felipe Correa on 9/2/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundManager<T: BackgroundTaskType>: NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
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
            debugPrint("Max attempts reached")
            item.completionHandler?(.failure(error))
            return
        }
        guard let sessionTask = prepareSessionTask(associatedTo: item) else {
            debugPrint("Don't able to create background session")
            context.deleteBackgroundItem(item)
            let error = NSError(domain: "Session task creation error", code: 500, userInfo: nil)
            item.completionHandler?(.failure(error))
            return
        }
        item.setStatus(.running)
        startTask(sessionTask, associatedWith: item)
        debugPrint("starting task: \(item.id)")
    }
    
    func prepareSessionTask(associatedTo backgroundItem: T) -> URLSessionTask? {
        fatalError("`prepareSessionTask` method must be implemented")
    }
    
    func executeTask(_ taks: T) { }
    
    private func startTask(_ task: URLSessionTask, associatedWith item: T) {
        item.setSessionId(task.taskIdentifier)
        context.saveBackgroundItem(item)
        task.earliestBeginDate = Date().addingTimeInterval(5)
        task.resume()
    }
    
    private func getBackgroundItemWithId(_ originId: Int?) -> T? {
        guard let id = originId, let backgroundTask = context.loadItem(with: id) else {
            debugPrint("Don't able to recover the background task for: \(String(describing: originId))")
            return nil
        }
        return backgroundTask
    }
    
    @discardableResult
    private func handleResponseFromTask(_ task: URLSessionTask) -> Bool {
        guard let backgroundTask = getBackgroundItemWithId(task.taskIdentifier) else {
            return false
        }
        guard let httpResponse = task.response as? HTTPURLResponse else {
            let error = NSError(domain: "Server not response", code: 1000, userInfo: nil)
            debugPrint("Server not response")
            backgroundTask.setStatus(.failed)
            backgroundTask.completionHandler?(.failure(error))
            context.saveBackgroundItem(backgroundTask)
            return false
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let error = NSError(domain: "Request failed", code: httpResponse.statusCode, userInfo: nil)
            debugPrint("Request failed")
            backgroundTask.setStatus(.failed)
            backgroundTask.completionHandler?(.failure(error))
            context.saveBackgroundItem(backgroundTask)
            return false
        }
        backgroundTask.setStatus(.completed)
        context.saveBackgroundItem(backgroundTask)
        backgroundTask.completionHandler?(.success(true))
        context.deleteBackgroundItem(backgroundTask)
        return true
    }
    
    func restartIncompletedTasks() {
        incompletedBackgroundItems { (incompletedItems) in
            incompletedItems?.forEach { self.startTask($0) }
        }
    }
    
    func incompletedBackgroundItems(_ completion: @escaping ((_ items: [T]?) -> Void)) { }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if let backgroundTask = getBackgroundItemWithId(task.taskIdentifier) {
                backgroundTask.setStatus(.failed)
                context.saveBackgroundItem(backgroundTask)
                backgroundTask.completionHandler?(.failure(error))
                debugPrint("didCompleteWithError")
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        handleResponseFromTask(dataTask)
        if let dataString = String(data: data, encoding: .utf8) {
            print("Response: \(dataString)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        /*
        let userDe = UserDefaults.standard
        let previous1 = userDe.value(forKey: "pre-didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous1+1, forKey: "pre-didFinishDownloadingTo")
        
        guard let downloadItem = getBackgroundItemWithId(downloadTask.taskIdentifier) else {
            return
        }
        print("Completed downloading task from: \(downloadItem.remotePathURL.absoluteString)")
        downloadItem.setStatus(.completed)
        context.saveBackgroundItem(downloadItem)
        downloadItem.completionHandler?(.success(downloadItem))
        
        do {
            try FileManager.default.moveItem(at: location, to: downloadItem.localPathURL)
            //            downloadItem.completionHandler?(.success(downloadItem.localPathURL))
        } catch let error {
            downloadItem.completionHandler?(.failure(error))
        }
        
        context.deleteBackgroundItem(downloadItem)
        
        let previous = userDe.value(forKey: "didFinishDownloadingTo") as? Int ?? 0
        userDe.set(previous+1, forKey: "didFinishDownloadingTo")
        */
        handleResponseFromTask(downloadTask)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
            print("completed background task")
        }
        
        NotificationManager.shared.sheduleNotificationInBackground(title: "Background Tasks finished")
    }
}
