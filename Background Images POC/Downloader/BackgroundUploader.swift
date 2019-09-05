//
//  BackgroundUploader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundUploader: BackgroundManager<UploadMultipartItem> {
    
    struct InputItem {
        let id: String
        let data: Data
    }
    
//    struct MultiPartForm {
//        let fileName: String
//        let mimeType: String
//        let formName: String
//    }
//
//    class MultipartUnit {
//        let data: Data
//        let formData: MultiPartForm
//        init(
//            data: Data,
//            formData: MultiPartForm
//            ){
//            self.data = data
//            self.formData = formData
//        }
//    }
    
    static let shared = BackgroundUploader()
    
    private override init() {
        super.init()
    }
    
    /*
    func upload(remoteURL: URL, cachePath: URL, id: String, data: Data, completionHandler: @escaping ForegroundCompletionHandler) {
        print("Scheduling to upload: \(cachePath)")
        let uploadItem = UploadBackgroundItem(id: id, remotePathURL: remoteURL, localPathURL: cachePath)
        uploadItem.contentData = data
        uploadItem.mimeType = "image/jpg"
        uploadItem.fileName = id + ".jpg"
        uploadItem.formDataName = "uploadedFile"
        uploadItem.completionHandler = completionHandler
        startTask(uploadItem)
    }
    */
    
    func upload(to remoteURL: URL, inputItems: [UploadBackgroundItem], completionHandler: @escaping ForegroundCompletionHandler) {
        let multipart = UploadMultipartItem(id: UUID().uuidString, remotePathURL: remoteURL, backgroundItems: inputItems)
        multipart.completionHandler = completionHandler
        startTask(multipart)
    }
    
    override func prepareSessionTask(associatedTo backgroundItem: UploadMultipartItem) -> URLSessionTask? {
        /*
        var contentData = backgroundItem.contentData
        if contentData == nil {
            contentData = try? Data(contentsOf: LocalFileManager.temporaryDirectory(appending: backgroundItem.id))
        }
        guard let fileName = backgroundItem.fileName, let mimeType = backgroundItem.mimeType,
            let data = contentData, let formName = backgroundItem.formDataName else {
                let error = NSError(domain: "Missing multipart form data", code: 404, userInfo: nil)
                backgroundItem.completionHandler?(.failure(error))
                return nil
        }
        let multiPartData = MultiPartForm(fileName: fileName, mimeType: mimeType, formName: formName)
        let request = requestFor(remote: backgroundItem.remotePathURL, with: [MultipartUnit(data: data , formData: multiPartData)])
        return session.uploadTask(withStreamedRequest: request)
        */
        let directory = LocalFileManager.temporaryDirectory()
        let request = requestWith(multipart: backgroundItem, directory: directory)
//        return session.uploadTask(withStreamedRequest: request)
        return session.uploadTask(with: request, fromFile: directory)
    }
    
    override func incompletedBackgroundItems(_ completion: @escaping (([UploadMultipartItem]?) -> Void)) {
        session.getTasksWithCompletionHandler { [weak self] (_, currentTasks, _) in
            let currentTasks = currentTasks.compactMap { $0.taskIdentifier }
            let items = self?.context.loadAllItemsFiltering(currentTasks, exclude: true)
            completion(items)
        }
    }
    
    private func requestWith(multipart: UploadMultipartItem, directory: URL) -> URLRequest {
        let alamofire = MultipartFormData()
        multipart.backgroundItems.forEach {
            alamofire.append($0.contentData!, withName: $0.formDataName, fileName: $0.fileName, mimeType: $0.mimeType)
        }
        var request = URLRequest(url: multipart.remotePathURL)
        request.setValue(alamofire.contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        try? alamofire.writeEncodedData(to: directory)
        return request
    }

}


extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

extension String {
    static func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

