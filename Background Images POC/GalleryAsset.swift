//
//  GalleryAsset.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

struct GalleryAsset: Equatable {
    
    let id: String
    let url: URL
    var state: BackgroundStatus = .pending
    
    // MARK: - Location
    
    func cachedLocalAssetURL() -> URL {
        let cacheURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileName = id
        return cacheURL.appendingPathComponent(fileName)
    }
    
    func cache2() -> URL {
        let cacheURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileName = id
        return cacheURL.appendingPathComponent(fileName)
    }
}
import UIKit
struct UploadGalleryAsset: Equatable {
    
    let fileName: String
    var filePathUrl: URL? = nil
    let image: UIImage
    var state: BackgroundStatus = .pending
    
    // MARK: - Location
    
    func cacheFilePath() -> URL {
        let cacheURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        return cacheURL.appendingPathComponent(fileName)
    }
}
