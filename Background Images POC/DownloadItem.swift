//
//  DownloadItem.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

enum DataRequestResult<T> {
    case success(T)
    case failure(Error)
}

typealias ForegroundDownloadCompletionHandler = ((_ result: DataRequestResult<URL>) -> Void)

class DownloadItem: Codable {
    let remoteURL: URL //URL of the asset to be downloaded
    let filePathURL: URL //URL of where the downloaded asset should be moved to on the local file system.
    var foregroundCompletionHandler: ForegroundDownloadCompletionHandler? //a closure to be called when the download is complete.
    
    // MARK: - Init
    
    private enum CodingKeys: String, CodingKey {
        case remoteURL
        case filePathURL
    }
    
    init(remoteURL: URL, filePathURL: URL) {
        self.remoteURL = remoteURL
        self.filePathURL = filePathURL
    }
}
