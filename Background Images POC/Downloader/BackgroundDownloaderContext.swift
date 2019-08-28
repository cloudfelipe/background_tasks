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
        userDefaults.synchronize()
    }
}
