//
//  BackgroundDownloader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloader: BackgroundManager<DownloadBackgroundItem> {
    
    static let shared = BackgroundDownloader()
    
    private override init() {
        super.init()
    }
    
    func download(remoteURL: URL, filePathURL: URL, completionHandler: @escaping ForegroundCompletionHandler) {
//        if let downloadItem = context.loadItem(withURL: remoteURL) {
//            print("Already downloading: \(remoteURL)")
//            downloadItem.completionHandler = completionHandler
//            restartPendingTasks()
//        } else {
//            print("Scheduling to download: \(remoteURL)")
//            let downloadItem = DownloadBackgroundItem(id: UUID().uuidString, remotePathURL: remoteURL, localPathURL: filePathURL)
//            downloadItem.completionHandler = completionHandler
////            startDownloadigItem(downloadItem)
//            startTask(downloadItem)
//        }
    }
    
    override func prepareSessionTask(associatedTo backgroundItem: DownloadBackgroundItem) -> URLSessionTask? {
        return session.downloadTask(with: backgroundItem.remotePathURL)
    }
    
    override func incompletedBackgroundItems(_ completion: @escaping (([DownloadBackgroundItem]?) -> Void)) {
        session.getTasksWithCompletionHandler { [weak self] (_, _, currentTasks) in
            let currentTasks = currentTasks.compactMap { $0.taskIdentifier }
            let items = self?.context.loadAllItemsFiltering(currentTasks, exclude: true)
            completion(items)
        }
    }
}
