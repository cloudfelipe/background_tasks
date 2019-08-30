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

class UploaderController: UIViewController {
    
    @IBOutlet weak var addPhotosButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedImages: [TLPHAsset] = [] {
        didSet {
            self.reloadImages()
//            self.uploadImages(selectedImages)
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
    
    let manager = SessionManager.init(configuration: URLSessionConfiguration.default)
    
    func uploadImage(_ image: TLPHAsset) {
        uploadImages([image])
    }
    
    let uploader = BackgroundUploader.shared
    
    func uploadImages(_ images: [TLPHAsset] ) {
        let url = URL(string: "http://localhost:3000/multiupload")!
        
        manager.upload(multipartFormData: { (multipart) in
            images.forEach({ (image) in
                let imageData = image.fullResolutionImage!.jpegData(compressionQuality: 0.9)!
                let fileName = image.originalFileName!
                let newName = fileName.prefix(upTo: fileName.lastIndex { $0 == "." } ?? fileName.endIndex)
                multipart.append(imageData, withName: "uploadedFile", fileName: "\(newName).jpg", mimeType: "image/jpeg")
            })
            
        }, usingThreshold: UInt64(0), to: "http://", method: .post, headers: nil, queue: nil) { (uploadResult) in
            switch uploadResult {
            case .success(let upload, _, let uploadUrl):
                let gallery = GalleryAsset(id: uploadUrl!.lastPathComponent, url: uploadUrl!)
                let cache = gallery.cache2()
//                FileMngr.moveItem(at: uploadUrl!, to: cache)
                upload.suspend()
                defer { upload.cancel() }
                if let almofireURL = uploadUrl {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    for (key, value) in upload.request!.allHTTPHeaderFields! {
                        request.addValue(value, forHTTPHeaderField: key)
                    }
//                    self.uploader.upload(url: request, filePathUrl: cache, completionHandler: { (result) in
//                        print("ENTER TO RESPONSE")
//                    })
                }
                upload.response(completionHandler: { (answer) in
//                    print(answer)
                })
                upload.uploadProgress(closure: { (progress) in
                    print(progress.localizedDescription!)
                })
            case .failure(let error):
                print("multipart error: \(error)")
            }
        }
    }
    let dataManager = DataManager()
    func uploadImages2(_ image: TLPHAsset) {
        let imageData = image.fullResolutionImage!.jpegData(compressionQuality: 0.9)!
        let fileName = image.originalFileName!
        let newName = fileName.prefix(upTo: fileName.lastIndex { $0 == "." } ?? fileName.endIndex)
        let uploadGallery = UploadGalleryAsset(fileName: "\(newName).jpg", filePathUrl: nil, image: image.fullResolutionImage!)
        dataManager.upload(uploadGallery) { (completed) in
            print("completed! \(completed)")
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        uploadImage(selectedImages[indexPath.row])
        uploadImages2(selectedImages[indexPath.row])
    }
}

extension UploaderController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.size.width - 14.0)/2.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
