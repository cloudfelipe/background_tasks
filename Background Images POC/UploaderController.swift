//
//  UploaderController.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Alamofire
import collection_view_layouts

class UploaderController: UIViewController {
    
    @IBOutlet weak var addPhotosButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var layout: BaseLayout!
    
    private var selectedImages: [UploadGalleryAsset] = [] {
        didSet {
            self.reloadImages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        layout = InstagramLayout()
        layout.delegate = self
        // All layouts support this configs
        layout.contentPadding = ItemsPadding(horizontal: 15, vertical: 15)
        layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func reloadImages() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.addPhotosButton.isHidden = self.selectedImages.count != 0
        }
    }
    
    @IBAction func addPhotosAction(_ sender: Any) {
        let pickerController = TLPhotosPickerViewController()
        pickerController.delegate = self
        var conf = TLPhotosPickerConfigure()
        conf.allowedVideo = false
        conf.allowedLivePhotos = false
        conf.allowedVideoRecording = false
        conf.allowedAlbumCloudShared = false
        pickerController.configure = conf
        self.present(pickerController, animated: true, completion: nil)
    }
}

extension UploaderController: TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        selectedImages = withTLPHAssets.map({ (image) -> UploadGalleryAsset in
            let fileName = image.originalFileName!
            let newName = fileName.prefix(upTo: fileName.lastIndex { $0 == "." } ?? fileName.endIndex)
            let uploadGallery = UploadGalleryAsset(fileName: "\(newName).jpg", filePathUrl: nil,
                                                   image: image.fullResolutionImage!, state: .pending)
            return uploadGallery
        })
    }
}

extension UploaderController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let asset = selectedImages[indexPath.row]
        cell.setupUploaderAsset(with: asset)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        cell.startUpload()
    }
}

extension UploaderController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.size.width - 14.0)/2.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension UploaderController: LayoutDelegate {
    func cellSize(indexPath: IndexPath) -> CGSize {
        return CGSize(width: 0.1, height: 0.1)
    }
}
