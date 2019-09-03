//
//  SessionWatcher.swift
//  Background Images POC
//
//  Created by Felipe Correa on 9/3/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

final class SessionWatcher {
    
    static let backgroundSession = ""
    
    static let shared = SessionWatcher()
    let context = BackgroundDownloaderContext<BackgroundItem>()
    
    private init() {
    }
    
    func processBackgroundItem(_ item: BackgroundItemType) {
//        switch item.status {
//        case .completed:
//            LocalFileManager.removeItemWithId(item.id)
//            context.deleteBackgroundItem(item as! BackgroundItem)
//        case .running:
//            if item is UploadBackgroundItem {
//                BackgroundUploader.shared.startTask(item as! UploadBackgroundItem)
//            } else if item is DownloadBackgroundItem {
//                BackgroundDownloader.shared.restartPendingTasks()
//            }
//            //Be sure if task was cancel and needs to be running again
//            break
//        case .pending:
//            //Attemp to run the task again
//            break
//        case .failed:
//            LocalFileManager.removeItemWithId(item.id)
//        }
    }
    
    func resumeAnyBackgroundTaks() {
        BackgroundUploader.shared.restartIncompletedTasks()
    }
    
    /// Remove from storage any finished background task than for some reason wasn't deleted.
    func purge() {
        let allItems = context.loadAllBackgroundItems()
        let completedItems = allItems.filter { $0.status == .completed }
        context.deleteItems(completedItems)
    }
}
