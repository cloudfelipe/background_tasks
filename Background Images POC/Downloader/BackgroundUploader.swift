//
//  BackgroundUploader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundUploader: BackgroundManager<UploadBackgroundItem> {
    
    struct MultiPartForm {
        let fileName: String
        let mimeType: String
        let formName: String
    }
    
    class MultipartUnit {
        let data: Data
        let formData: MultiPartForm
        init(
            data: Data,
            formData: MultiPartForm
            ){
            self.data = data
            self.formData = formData
        }
    }
    
    static let shared = BackgroundUploader()
    
    private override init() {
        super.init()
    }
    
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
    
    func upload(to remoteURL: URL, cachedElementsWithIds ids: [String], completionHandler: @escaping ForegroundCompletionHandler) {
        let items = ids.map {
            let uploadItem = UploadBackgroundItem(id: $0, remotePathURL: remoteURL, localPathURL: remoteURL)
            uploadItem.contentData = data
            uploadItem.mimeType = "image/jpg"
            uploadItem.fileName = id + ".jpg"
            uploadItem.formDataName = "uploadedFile"
        }
    }
    
    override func prepareSessionTask(associatedTo backgroundItem: UploadBackgroundItem) -> URLSessionTask? {
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
    }
    
    override func incompletedBackgroundItems(_ completion: @escaping (([UploadBackgroundItem]?) -> Void)) {
        session.getTasksWithCompletionHandler { [weak self] (_, currentTasks, _) in
            let currentTasks = currentTasks.compactMap { $0.taskIdentifier }
            let items = self?.context.loadAllItemsFiltering(currentTasks, exclude: true)
            completion(items)
        }
    }
    
    private func requestFor(remote url: URL, with multipartUnits: [MultipartUnit]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = String.generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        //define the data post parameter
        multipartUnits.forEach {
            body.append(prepareMultipartUnit(boundary: boundary, $0))
        }
        request.httpBody = body
        return request
    }

    func prepareMultipartUnit(boundary: String, _ multipart: MultipartUnit) -> Data {
        var bodyUnit = Data()
        let fname = multipart.formData.fileName
        let mimetype = multipart.formData.mimeType
        let formItemName = multipart.formData.formName
        //define the data post parameter
        bodyUnit.append("--\(boundary)\r\n", using: .utf8)
        bodyUnit.append("Content-Disposition:form-data; name=\"\(formItemName)\"; filename=\"\(fname)\"\r\n", using: .utf8)
        bodyUnit.append("Content-Type: \(mimetype)\r\n\r\n", using: .utf8)
        bodyUnit.append(multipart.data)
        bodyUnit.append("\r\n", using: .utf8)
        bodyUnit.append("--\(boundary)--\r\n", using: .utf8)
        return bodyUnit
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

