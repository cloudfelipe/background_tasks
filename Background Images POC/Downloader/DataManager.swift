//
//  DataManager.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation
import UIKit

struct LoadAssetResult: Equatable {
    let asset: GalleryAsset
    let image: UIImage
}

enum APIError: Error {
    case unknown
    case missingData
    case serialization
    case invalidData
}

class DataManager {
    func load(asset: GalleryAsset, remoteLoadHandler: @escaping ((_ result: DataRequestResult<LoadAssetResult>) -> Void)) -> UIImage? {
        if let image = UIImage(contentsOfFile: asset.cachedLocalAssetURL().path) {
            return image
        } else {
            remotelyLoad(asset, remoteLoadHandler: remoteLoadHandler)
        }
        return nil
    }
    
    private func remotelyLoad(_ asset: GalleryAsset, remoteLoadHandler: @escaping ((_ result: DataRequestResult<LoadAssetResult>) -> Void)) {
        let downloader = BackgroundDownloader.shared
        
        downloader.download(remoteURL: asset.url, filePathURL: asset.cachedLocalAssetURL()) { (result) in
            switch result {
            case .success(let url):
                guard let image = self.getImage(from: url) else {
                    remoteLoadHandler(.failure(APIError.invalidData))
                    return
                }
                let loadResult = LoadAssetResult(asset: asset, image: image)
                let dataRequestResult = DataRequestResult<LoadAssetResult>.success(loadResult)
                
                DispatchQueue.main.async {
                    remoteLoadHandler(dataRequestResult)
                }
            case .failure(let error):
                print("Error in data manager: \(error)")
                remoteLoadHandler(.failure(error))
            }
        }
    }
    
    private func getImage(from url: URL) -> UIImage? {
        var retrievedData: Data? = nil
        do {
            retrievedData = try Data(contentsOf: url)
        } catch {
            return nil
        }
        
        guard let imageData = retrievedData, let image = UIImage(data: imageData) else {
            return nil
        }
        
        return image
    }
}