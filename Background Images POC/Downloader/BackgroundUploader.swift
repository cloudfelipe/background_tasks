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
        let mimyType: String
        let formName: String
    }
    
    static let shared = BackgroundUploader()
    
    private override init() {
        super.init()
    }
    
    func upload(remoteURL: URL, cachePath: URL, id: String, fileName: String, data: Data, completionHandler: @escaping ForegroundCompletionHandler) {
        print("Scheduling to upload: \(cachePath)")
        let uploadItem = UploadBackgroundItem(id: id, remotePathURL: remoteURL, localPathURL: cachePath)
        uploadItem.contentData = data
        uploadItem.mimeType = "image/jpg"
        uploadItem.fileName = fileName
        uploadItem.formDataName = "uploadedFile"
        uploadItem.completionHandler = completionHandler
        startTask(uploadItem)
    }
    
    override func executeTask(_ taks: UploadBackgroundItem) {
        var contentData = try? Data(contentsOf: taks.localPathURL)
        contentData = contentData ?? taks.contentData
        guard let fileName = taks.fileName, let mimeType = taks.mimeType,
            let data = contentData, let formName = taks.formDataName else {
                let error = NSError(domain: "Missing multipart form data", code: 404, userInfo: nil)
                taks.completionHandler?(.failure(error))
                return
        }
        let multiPartData = MultiPartForm(fileName: fileName, mimyType: mimeType, formName: formName)
        let request = requestFor(remote: taks.remotePathURL, with: data, formData: multiPartData)
        let task = session.uploadTask(withStreamedRequest: request)
        task.earliestBeginDate = Date().addingTimeInterval(5)
        task.resume()
    }
    
    private func requestFor(remote url: URL, with data: Data, formData: MultiPartForm) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = String.generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        let fname = formData.fileName
        let mimetype = formData.mimyType
        let formItemName = formData.formName
        //define the data post parameter
        body.append("--\(boundary)\r\n", using: .utf8)
        body.append("Content-Disposition:form-data; name=\"\(formItemName)\"; filename=\"\(fname)\"\r\n", using: .utf8)
        body.append("Content-Type: \(mimetype)\r\n\r\n", using: .utf8)
        body.append(data)
        body.append("\r\n", using: .utf8)
        body.append("--\(boundary)--\r\n", using: .utf8)
        request.httpBody = body
        return request
    }
}


extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
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

