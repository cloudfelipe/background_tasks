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
    private var uploadAsset: UploadGalleryAsset?
    @IBOutlet weak var errorImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func updateVisibility(for status: BackgroundStatus) {
        DispatchQueue.main.async {
            self.imageView.alpha = 0.4
            self.activityIndicator.stopAnimating()
            self.errorImageView.isHidden = true
            switch status {
            case .completed:
                self.imageView.alpha = 1
            case .pending:
                break
            case .running:
                self.activityIndicator.startAnimating()
            case .failed:
                self.errorImageView.isHidden = false
            }
        }
    }
    
    func setupUploaderAsset(with image: UploadGalleryAsset) {
        uploadAsset = image
        imageView.image = image.image
    }
    
    func startUpload() {
        self.uploadAsset?.state = .running
        self.updateVisibility(for: self.uploadAsset!.state)
        assetDataManager.upload(uploadAsset!) { (result) in
            if result {
                self.uploadAsset?.state = .completed
            } else {
                self.uploadAsset?.state = .failed
            }
            self.updateVisibility(for: self.uploadAsset!.state)
        }
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
