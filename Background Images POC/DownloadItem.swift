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

typealias ForegroundCompletionHandler = ((_ result: DataRequestResult<BackgroundItemType>) -> Void)

protocol BackgroundItemType: Codable {
    var id: String { get }
    var taskIdentifier: Int { get }
    var attempts: Int { get }
    var remotePathURL: URL { get }
    var localPathURL: URL { get }
    var fileName: String? { get }
    var mimeType: String? { get }
    var status: BackgroundStatus { get }
    var completionHandler: ForegroundCompletionHandler? { get }
    
    func newAttempt()
    func setStatus(_ newStatus: BackgroundStatus)
    func setSessionId(_ id: Int)
}

enum BackgroundStatus: Int, Codable {
    case pending
    case running
    case completed
    case failed
}

class BackgroundItem: BackgroundItemType {
    
    var id: String
    var taskIdentifier: Int = -1
    var remotePathURL: URL
    var localPathURL: URL
    var completionHandler: ForegroundCompletionHandler?
    var attempts: Int = 0
    var status: BackgroundStatus
    var fileName: String?
    var mimeType: String?
    var formDataName: String?
    
    func newAttempt() {
        attempts += 1
    }
    
    func setStatus(_ newStatus: BackgroundStatus) {
        self.status = newStatus
    }
    
    func setSessionId(_ id: Int) {
        self.taskIdentifier = id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case taskIdentifier
        case remotePathURL
        case localPathURL
        case attempts
        case status
        case fileName
        case mimeType
        case formDataName
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
}

final class DownloadBackgroundItem: BackgroundItem {}
