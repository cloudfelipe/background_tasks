//
//  BackgroundDownloaderContext.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundDownloaderContext<T: BackgroundItemType> {
    
    private let backgroundTask = "BACKGROUND_TASK:"
    
    private var inMemoryDownloadItems: [String: T] = [:]
    private let userDefaults = UserDefaults.standard
    
    private func identifier(with id: Int) -> String {
        return "\(backgroundTask)\(id)"
    }
    
    func loadAllPendingItems() -> [T] {
        return userDefaults.dictionaryRepresentation().keys.compactMap { (key) -> T? in
            key.hasPrefix(backgroundTask) ? self.loadItemFromStorage(with: key) : nil
        }
    }
    
    func loadItem(with taskId: Int) -> T? {
        if let downloadItem = inMemoryDownloadItems[identifier(with: taskId)] {
            return downloadItem
        } else if let downloadItem = loadItemFromStorage(with: identifier(with: taskId)) {
            inMemoryDownloadItems[identifier(with: taskId)] = downloadItem
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
        inMemoryDownloadItems[identifier(with: item.taskIdentifier)] = item
        let encodedData = try? JSONEncoder().encode(item)
        userDefaults.set(encodedData, forKey: identifier(with: item.taskIdentifier))
    }
    
    func deleteBackgroundItem(_ item: T) {
        inMemoryDownloadItems[identifier(with: item.taskIdentifier)] = nil
        userDefaults.removeObject(forKey: identifier(with: item.taskIdentifier))
    }
    
    func deleteItems(_ items: [T]) {
        items.forEach { deleteBackgroundItem($0) }
    }
}

extension BackgroundDownloaderContext {
    func loadAllItemsFiltering(_ ids: [Int], exclude: Bool) -> [T] {
        let allItems = loadAllPendingItems()
        return allItems.filter { (item) -> Bool in
            if exclude {
                return !ids.contains(item.taskIdentifier)
            } else {
                return ids.contains(item.taskIdentifier)
            }
        }
    }
}

func printBackgroundItems() {
    let userDefault = UserDefaults.standard
    for (key, value) in userDefault.dictionaryRepresentation() {
        if key.contains("BACKGROUND_TASK:") {
            print("\(key) = \(value) \n")
        }
    }
}
