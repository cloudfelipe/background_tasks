//
//  LocalFileManager.swift
//  Background Images POC
//
//  Created by Felipe Correa on 9/3/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

struct TemporalFile {
    var id: String
    var localPathURL: URL
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
//        let tempURL =  FileManager.default
//            .temporaryDirectory
//            .appendingPathComponent(cacheId, isDirectory: false)
        let tempURL = temporaryDirectory(appending: cacheId)
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
//        let manager = FileManager.default
        let tempURL = temporaryDirectory(appending: id)
        do {
            try FileManager.default.removeItem(at: tempURL)
        } catch let error {
            debugPrint(error)
        }
    }
    
    class func temporaryDirectory(appending id: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(id, isDirectory: false)
    }
    
    class func temporaryDirectory() -> URL {
        return temporaryDirectory(appending: UUID().uuidString)
    }
    
    enum URLMethod: String {
        case get
        case post
    }
}
