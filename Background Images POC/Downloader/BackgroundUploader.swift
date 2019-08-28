//
//  BackgroundUploader.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class BackgroundUploader: NSObject {
    
    private var session: URLSession!
    static let shared = BackgroundUploader()
    var backgroundCompletionHandler: (() -> Void)?
    
    private let context = BackgroundDownloaderContext<BackgroundItem>()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "Background.Uploader.Session")
        session =  URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func upload(url: URLRequest, filePathUrl: URL, completionHandler: @escaping ForegroundDownloadCompletionHandler) {
        print("Scheduling to upload: \(filePathUrl)")
//        let uploadItem = UploadItem(filePathURL: filePathUrl)
//        uploadItem.completionHandler = completionHandler
//        
//        let task = session.uploadTask(with: url, fromFile: filePathUrl)
//        task.earliestBeginDate = Date().addingTimeInterval(5)
//        task.resume()
    }
    
    func upload(remoteURL: URL, cachePath: URL, fileName: String, data: Data, completionHandler: @escaping ForegroundCompletionHandler) {
        let uploadItem = BackgroundItem(remotePathURL: remoteURL, localPathURL: cachePath)
        uploadItem.completionHandler = completionHandler
        let request = uploadImageToServerFromApp(url: remoteURL, data: data)
        let task = session.uploadTask(withStreamedRequest: request)
        context.saveBackgroundItem(uploadItem)
        task.earliestBeginDate = Date().addingTimeInterval(5)
        task.resume()
        print("Scheduling upload task")
    }
}

extension BackgroundUploader: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("ERORR UPLOADING: \(error)")
        } else {
            print("Completed uploading task")
            let url = task.currentRequest!.url!
            let task = context.loadItem(withURL: url)
            task?.completionHandler?(.success(url))
            context.deleteBackgroundItem(task!)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
            print("completed background task")
        }
    }
}

class FileMngr {
    class func moveItem(at: URL, to: URL) {
        do {
            try FileManager.default.copyItem(at: at, to: to)
        } catch let error {
            print("error file manager: \(error)")
        }
    }
    
    enum URLMethod: String {
        case get
        case post
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

func uploadImageToServerFromApp(url: URL, data: Data) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let boundary = generateBoundaryString()
    //define the multipart request type
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    var body = Data()
    let fname = "image.jpg"
    let mimetype = "image/jpg"
    //define the data post parameter
    body.append("--\(boundary)\r\n", using: .utf8)
    body.append("Content-Disposition:form-data; name=\"uploadedFile\"; filename=\"\(fname)\"\r\n", using: .utf8)
    body.append("Content-Type: \(mimetype)\r\n\r\n", using: .utf8)
    body.append(data)
    body.append("\r\n", using: .utf8)
    body.append("--\(boundary)--\r\n", using: .utf8)
    request.httpBody = body
    return request
}

func generateBoundaryString() -> String
{
    return "Boundary-\(NSUUID().uuidString)"
}
