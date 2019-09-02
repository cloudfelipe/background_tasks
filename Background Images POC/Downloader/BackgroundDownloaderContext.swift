//
//  BackgroundDownloaderContext.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloaderContext<T: BackgroundItemType> {
    
    let backgroundTask = "BACKGROUND_TASK:"
    
    private var inMemoryDownloadItems: [String: T] = [:]
    private let userDefaults = UserDefaults.standard
    
    private func identifier(with associated: URL) -> String {
        return backgroundTask + associated.path
    }
    
    func loadAllPendingItems() -> [T] {
        return userDefaults.dictionaryRepresentation().keys.compactMap { (key) -> T? in
            key.hasPrefix(backgroundTask) ? self.loadItemFromStorage(with: key) : nil
        }
    }
    
    func loadItem(withURL url: URL) -> T? {
        if let downloadItem = inMemoryDownloadItems[identifier(with: url)] {
            return downloadItem
        } else if let downloadItem = loadItemFromStorage(with: identifier(with: url)) {
            inMemoryDownloadItems[identifier(with: downloadItem.remotePathURL)] = downloadItem
            return downloadItem
        }
        return nil
    }
    
    private func loadItemFromStorage(with key: String) -> T? {
        guard let encodedData = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        let downloadItem = try? JSONDecoder().decode(T.self, from: encodedData)
        return downloadItem
    }
    
    func saveBackgroundItem(_ item: T) {
        inMemoryDownloadItems[identifier(with: item.remotePathURL)] = item
        let encodedData = try? JSONEncoder().encode(item)
        userDefaults.set(encodedData, forKey: identifier(with: item.remotePathURL))
        userDefaults.synchronize()
    }
    
    func deleteBackgroundItem(_ item: T) {
        inMemoryDownloadItems[identifier(with: item.remotePathURL)] = nil
        userDefaults.removeObject(forKey: identifier(with: item.remotePathURL))
    }
    
    func deleteItems(_ items: [T]) {
        items.forEach { deleteBackgroundItem($0) }
    }
}

extension BackgroundDownloaderContext {
    func loadAllItemsFiltering(_ urlList: [URL], exclude: Bool) -> [T] {
        let allItems = loadAllPendingItems()
        return allItems.filter { (item) -> Bool in
            if exclude {
                return !urlList.contains(item.remotePathURL)
            } else {
                return urlList.contains(item.remotePathURL)
            }
        }
    }
}


class LocalFileManager {
    class func moveItem(at: URL, to: URL) {
        do {
            try FileManager.default.copyItem(at: at, to: to)
        } catch let error {
            print("error file manager: \(error)")
        }
    }
    
    class func moveToTemp(data: Data) -> TemporalFile? {
        let cacheId = UUID().uuidString
        let tempURL =  FileManager.default
            .temporaryDirectory
            .appendingPathComponent(cacheId, isDirectory: false)
        do {
            try data.write(to: tempURL)
            return TemporalFile(id: cacheId, localPathURL: tempURL)
        } catch {
            print("Handle the error, i.e. disk can be full")
            return nil
        }
    }
    
    class func moveToTemporal(data: Data) -> (cacheId: String, cacheURL: URL)? {
        let cacheId = UUID().uuidString
        let tempURL =  FileManager.default
            .temporaryDirectory
            .appendingPathComponent(cacheId, isDirectory: false)
        do {
            try data.write(to: tempURL)
            return (cacheId, tempURL)
        } catch {
            print("Handle the error, i.e. disk can be full")
            return nil
        }
    }
    
    class func remoteItemAt(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print(error)
        }
    }
    
    class func removeAllItemsIn(_ urls: [URL]) {
        urls.forEach { remoteItemAt($0) }
    }
    
    class func removeAllItemsByID(_ ids: [String]) {
        ids.forEach {
            removeItemWithId($0)
        }
    }
    
    class func removeItemWithId(_ id: String) {
        let manager = FileManager.default
        let tempURL =  manager.temporaryDirectory
        let path = tempURL.appendingPathComponent(id)
        do {
            try FileManager.default.removeItem(at: path)
        } catch let error {
            print(error)
        }
    }
    
    enum URLMethod: String {
        case get
        case post
    }
}
