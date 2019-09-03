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
    
    override func prepareSessionTask(associatedTo backgroundItem: UploadBackgroundItem) -> URLSessionTask? {
        var contentData = try? Data(contentsOf: backgroundItem.localPathURL)
        contentData = contentData ?? backgroundItem.contentData
        guard let fileName = backgroundItem.fileName, let mimeType = backgroundItem.mimeType,
            let data = contentData, let formName = backgroundItem.formDataName else {
                let error = NSError(domain: "Missing multipart form data", code: 404, userInfo: nil)
                backgroundItem.completionHandler?(.failure(error))
                return nil
        }
        let multiPartData = MultiPartForm(fileName: fileName, mimyType: mimeType, formName: formName)
        let request = requestFor(remote: backgroundItem.remotePathURL, with: data, formData: multiPartData)
        return session.uploadTask(withStreamedRequest: request)
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

