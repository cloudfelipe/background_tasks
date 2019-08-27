//
//  UploaderController.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit
import TLPhotoPicker

class UploaderController: UIViewController {
    
    @IBOutlet weak var addPhotosButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedImages: [TLPHAsset] = [] {
        didSet {
            self.reloadImages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
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
        selectedImages = withTLPHAssets
    }
}

extension UploaderController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let image = selectedImages[indexPath.row]
        cell.setupImage(with: image.fullResolutionImage)
        return cell
    }
}

extension UploaderController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.size.width - 14.0)/2.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
