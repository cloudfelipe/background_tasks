//
//  AssetFactory.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import Foundation

class GalleryAssetFactory {
    class func assentFromURLString(_ string: String, id: String) -> GalleryAsset? {
        guard let url = URL(string: string) else {
            print("Can't get URL from: \(string)")
            return nil
        }
        return GalleryAsset(id: id, url: url)
    }
    
    class func assentsFromURLStringList(_ strings: [String]) -> [GalleryAsset] {
        var new = [GalleryAsset]()
        for (i, file) in strings.enumerated() {
            new.append(GalleryAssetFactory.assentFromURLString(file, id: String(i))!)
        }
        return new
    }
}

extension URL {
    func fileName() -> String {
        return self.deletingPathExtension().lastPathComponent
    }
}
