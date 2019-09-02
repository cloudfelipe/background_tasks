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

typealias ForegroundCompletionHandler = ((_ result: DataRequestResult<BackgroundItemType>) -> Void)

protocol BackgroundItemType: Codable {
    var id: String { get }
    var attempts: Int { get }
    var remotePathURL: URL { get }
    var localPathURL: URL { get }
    var fileName: String? { get }
    var mimeType: String? { get }
    var status: BackgroundStatus { get }
    var completionHandler: ForegroundCompletionHandler? { get }
    
    func newAttempt()
    func setStatus(_ newStatus: BackgroundStatus)
}

enum BackgroundStatus: Int, Codable {
    case pending
    case running
    case completed
}

struct TemporalFile {
    var id: String
    var localPathURL: URL
}

class BackgroundItem: BackgroundItemType {
    
    var id: String
    var remotePathURL: URL
    var localPathURL: URL
    var completionHandler: ForegroundCompletionHandler?
    var attempts: Int = 0
    var status: BackgroundStatus
    var fileName: String?
    var mimeType: String?
    
    func newAttempt() {
        attempts += 1
    }
    
    func setStatus(_ newStatus: BackgroundStatus) {
        self.status = newStatus
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case remotePathURL
        case localPathURL
        case attempts
        case status
        case fileName
        case mimeType
    }
    
    init(id: String, remotePathURL: URL, localPathURL: URL, status: BackgroundStatus = .pending) {
        self.id = id
        self.remotePathURL = remotePathURL
        self.localPathURL = localPathURL
        self.status = status
    }
}

final class UploadBackgroundItem: BackgroundItem {
    var contentData: Data?
    var formDataName: String?
}
final class DownloadBackgroundItem: BackgroundItem {}
