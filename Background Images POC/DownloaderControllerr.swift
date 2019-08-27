//
//  ViewController.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit

class DownloaderController: UIViewController {
    
    private var assetDataManager = DataManager()
    
    private var downloadAssents: [GalleryAsset] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Fetching images from
        var imagesURLs = [String]()
        for i in 0..<20 {
            imagesURLs.append("https://picsum.photos/id/\(i)/2000/2000")
        }
        downloadAssents = GalleryAssetFactory.assentsFromURLStringList(imagesURLs)
//        addPhotosButton.isHidden = true
        
//        let image4k = GalleryAsset(id: "4k", url: URL(string: "https://thewallpaper.co//wp-content/uploads/2016/10/large-wallpaper-hd-hd-background-wallpapers-amazing-cool-tablet-smart-phone-4k-high-definition-1920x1080.jpg")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    private func reloadImages() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension DownloaderController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadAssents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let image = downloadAssents[indexPath.row]
        cell.setupAssent(image)
        return cell
    }
}

extension DownloaderController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (view.frame.size.width - 14.0)/2.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
