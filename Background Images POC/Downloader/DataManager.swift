//
//  DataManager.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation
import UIKit

struct LoadAssetResult: Equatable {
    let asset: GalleryAsset
    let image: UIImage
}

enum APIError: Error {
    case unknown
    case missingData
    case serialization
    case invalidData
}

class DataManager {
    func load(asset: GalleryAsset, remoteLoadHandler: @escaping ((_ result: DataRequestResult<LoadAssetResult>) -> Void)) -> UIImage? {
//        print("temp \(asset.cachedLocalAssetURL())")
        if let image = UIImage(contentsOfFile: asset.cachedLocalAssetURL().path) {
            return image
        } else {
            remotelyLoad(asset, remoteLoadHandler: remoteLoadHandler)
        }
        return nil
    }
    
    private func remotelyLoad(_ asset: GalleryAsset, remoteLoadHandler: @escaping ((_ result: DataRequestResult<LoadAssetResult>) -> Void)) {
        let downloader = BackgroundDownloader.shared
        
        downloader.download(remoteURL: asset.url, filePathURL: asset.cachedLocalAssetURL()) { (result) in
            switch result {
            case .success(let item):
                guard let image = self.getImage(from: item.localPathURL) else {
                    remoteLoadHandler(.failure(APIError.invalidData))
                    return
                }
                let loadResult = LoadAssetResult(asset: asset, image: image)
                let dataRequestResult = DataRequestResult<LoadAssetResult>.success(loadResult)
                
                DispatchQueue.main.async {
                    remoteLoadHandler(dataRequestResult)
                }
            case .failure(let error):
                print("Error in data manager: \(error)")
                remoteLoadHandler(.failure(error))
            }
        }
    }
    
    func upload(_ asset: UploadGalleryAsset, completionHandler: @escaping((_ result: Bool) -> Void)) {
        let url = URL(string: "http://9a42f41e.ngrok.io/upload")!
        let uploader = BackgroundUploader.shared
        let imageData = asset.image.jpegData(compressionQuality: 0.9)!
        guard let cache = LocalFileManager.moveToTemp(data: imageData) else {
            completionHandler(false)
            return
        }
        uploader.upload(remoteURL: url, cachePath: cache.localPathURL, id: cache.id, data: imageData) { (result) in
            switch result {
            case .success(let backgroundItem):
                print("image uploaded")
                SessionWatcher.shared.processBackgroundItem(backgroundItem as! BackgroundItem)
                completionHandler(true)
            case .failure(let error):
                print(error)
                completionHandler(false)
            }
        }
    }
    
    func pendingTasks() {
        
    }
    
    private func getImage(from url: URL) -> UIImage? {
        var retrievedData: Data? = nil
        do {
            retrievedData = try Data(contentsOf: url)
        } catch {
            return nil
        }
        
        guard let imageData = retrievedData, let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
}

final class SessionWatcher {
    
    static let backgroundSession = ""
    
    static let shared = SessionWatcher()
    let context = BackgroundDownloaderContext<BackgroundItem>()
//    let fieManager = LocalFileManager()
    
    private init() {
    }
    
    func processBackgroundItem(_ item: BackgroundItemType) {
//        let dataContex = BackgroundDownloaderContext<BackgroundItem>()
        switch item.status {
        case .completed:
            LocalFileManager.removeItemWithId(item.id)
//            dataContex.deleteBackgroundItem(item)
            break
        case .running:
            if item is UploadBackgroundItem {
                BackgroundUploader.shared.startTask(item as! UploadBackgroundItem)
            } else if item is DownloadBackgroundItem {
                BackgroundDownloader.shared.restartPendingTasks()
            }
            //Be sure if task was cancel and needs to be running again
            
            break
        case .pending:
            //Attemp to run the task again
            break
        case .failed:
            break
        }
    }
    
    func watch() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "")
        let session = URLSession(configuration: configuration)
        session.getTasksWithCompletionHandler { [weak self] (_, uploadTasks, downloadTasks) in
            if let incompletedDownloadItems = self?.incompletedItems(excluding: downloadTasks, for: DownloadBackgroundItem.self) {
                BackgroundDownloader.shared.restartPendingTasks(incompletedDownloadItems)
            }
            if let incompletedUploadItem = self?.incompletedItems(excluding: uploadTasks, for: UploadBackgroundItem.self) {
                BackgroundUploader.shared.restartPendingTasks(incompletedUploadItem)
            }
        }
    }
    
    private func incompletedItems<T: BackgroundItemType>(excluding tasks: [URLSessionTask], for type: T.Type) -> [T] {
        let currentDownloading = tasks.compactMap { $0.taskIdentifier }
        let context = BackgroundDownloaderContext<T>()
        return context.loadAllItemsFiltering(currentDownloading, exclude: true)
    }
    
    func purge() {
        let dataContex = BackgroundDownloaderContext<BackgroundItem>()
        let allItems = dataContex.loadAllPendingItems()
        let completedItems = allItems.filter { $0.status == .completed }
        LocalFileManager.removeAllItemsByID(completedItems.map { $0.id })
        dataContex.deleteItems(completedItems)
    }
}
