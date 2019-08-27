//
//  ImageCollectionViewCell.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    private var assetDataManager = DataManager()
    private var asset: GalleryAsset?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func setupImage(with image: UIImage?) {
        imageView.image = image
    }
    
    func setupAssent(_ assent: GalleryAsset) {
        self.asset = assent
        let image = assetDataManager.load(asset: assent) { [weak self] (result) in
            switch result {
            case .success(let finalResult):
                if finalResult.asset == self?.asset {
                    print("downloaded image")
                    self?.setImage(finalResult.image)
                }
            case .failure(let error):
                print("Error getting image \(error)")
            }
        }
        
        if image != nil {
            print("Cached image")
            setImage(image)
        }
    }
    
    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
