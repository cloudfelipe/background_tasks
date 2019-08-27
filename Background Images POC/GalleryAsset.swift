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
    
    // MARK: - Location
    
    func cachedLocalAssetURL() -> URL {
        let cacheURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileName = id
        return cacheURL.appendingPathComponent(fileName)
    }
}
