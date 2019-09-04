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

protocol UploadMultipartType: Codable {
    var id: String { get }
    var taskIdentifier: Int { get }
    var attempts: Int { get }
//    var completionHandler: ForegroundCompletionHandler? { get }
    var status: BackgroundStatus { get }
    var backgroundItems: [BackgroundItemType] { get }
    
    func newAttempt()
    func setStatus(_ newStatus: BackgroundStatus)
    func setSessionId(_ id: Int)
}

protocol BackgroundItemType: Codable {
    var id: String { get }
    var fileName: String? { get }
    var mimeType: String? { get }
    var formDataName: String? { get }
}

enum BackgroundStatus: Int, Codable {
    case pending
    case running
    case completed
    case failed
}

class BackgroundItem: BackgroundItemType {
    
    var id: String
    var fileName: String?
    var mimeType: String?
    var formDataName: String?
    
    init(id: String, fileName: String?, mimeType: String?, formDataName: String?) {
        self.id = id
        self.fileName = fileName
        self.mimeType = mimeType
        self.formDataName = formDataName
    }
}

final class UploadBackgroundItem: BackgroundItem {
    var contentData: Data?
}

final class UploadMultipartItem: UploadMultipartType {
   
    var id: String
    var taskIdentifier: Int = -1
    var remotePathURL: URL
//    var completionHandler: ForegroundCompletionHandler?
    var attempts: Int = 0
    var status: BackgroundStatus
    var backgroundItems: [BackgroundItemType]
    
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
        case attempts
        case status
        case backgroundItems
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .)
//        self.items = try
//    }
    
    init(id: String, remotePathURL: URL, backgroundItems: [BackgroundItemType], status: BackgroundStatus = .pending) {
        self.id = id
        self.backgroundItems = backgroundItems
        self.remotePathURL = remotePathURL
        self.status = status
    }
}

final class DownloadBackgroundItem: BackgroundItem {}
