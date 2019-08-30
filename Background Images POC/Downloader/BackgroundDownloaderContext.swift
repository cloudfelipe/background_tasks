//
//  BackgroundDownloaderContext.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloaderContext<T: BackgroundItemType> {
    
    private var inMemoryDownloadItems: [URL: T] = [:]
    private let userDefaults = UserDefaults.standard
    
    func loadItem(withURL url: URL) -> T? {
        if let downloadItem = inMemoryDownloadItems[url] {
            return downloadItem
        } else if let downloadItem = loadItemFromStorage(withURL: url) {
            inMemoryDownloadItems[downloadItem.remotePathURL] = downloadItem
            return downloadItem
        }
        return nil
    }
    
    private func loadItemFromStorage(withURL url: URL) -> T? {
        guard let encodedData = userDefaults.object(forKey: url.path) as? Data else {
            return nil
        }
        let downloadItem = try? JSONDecoder().decode(T.self, from: encodedData)
        return downloadItem
    }
    
    func saveBackgroundItem(_ item: T) {
        inMemoryDownloadItems[item.remotePathURL] = item
        let encodedData = try? JSONEncoder().encode(item)
        userDefaults.set(encodedData, forKey: item.remotePathURL.path)
        userDefaults.synchronize()
    }
    
    func deleteBackgroundItem(_ item: T) {
        inMemoryDownloadItems[item.remotePathURL] = nil
        userDefaults.removeObject(forKey: item.remotePathURL.path)
//        userDefaults.synchronize()
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
    
    enum URLMethod: String {
        case get
        case post
    }
}
