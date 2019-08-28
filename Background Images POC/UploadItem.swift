//
//  UploadItem.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class UploadItem: Codable {
    
    let remoteURL: URL
    let cacheFilePath: URL
    
    var completionHandler: ForegroundUploadCompletionHandler?
    
    private enum CodingKeys: String, CodingKey {
        case remoteURL
        case cacheFilePath
    }
    
    init(remoteURL: URL, cacheFilePath: URL) {
        self.remoteURL = remoteURL
        self.cacheFilePath = cacheFilePath
    }
}
