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
typealias ForegroundUploadCompletionHandler = ((_ result: DataRequestResult<Bool>) -> Void)

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

typealias ForegroundCompletionHandler = ((_ result: DataRequestResult<URL>) -> Void)

protocol BackgroundItemType: Codable {
    var attempts: Int { get }
    var remotePathURL: URL { get }
    var localPathURL: URL { get }
    var completionHandler: ForegroundCompletionHandler? { get }
    func newAttempt()
}

class BackgroundItem: BackgroundItemType {
    
    var id: String
    var remotePathURL: URL
    var localPathURL: URL
    var completionHandler: ForegroundCompletionHandler?
    var attempts: Int = 0
    
    func newAttempt() {
        attempts += 1
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case remotePathURL
        case localPathURL
        case attempts
    }
    
    init(id: String, remotePathURL: URL, localPathURL: URL) {
        self.id = id
        self.remotePathURL = remotePathURL
        self.localPathURL = localPathURL
    }
}
