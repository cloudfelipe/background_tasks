//
//  MainViewController.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/27/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import EmeraldIOS

class MainViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    private weak var segmentedController: SegmentedPagerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedController?.setSegmentedBarTheme(.navigation)
        let downloadingVC = DownloaderController.instantiate(fromAppStoryboard: .Main)
        downloadingVC.title = "Downloading"
        let uploadingVC = UploaderController.instantiate(fromAppStoryboard: .Main)
        uploadingVC.title = "Uploading"
        setupSegmentedController(controllers: [uploadingVC])
        setupContraints()
    }
    
    private func setupSegmentedController(controllers: [UIViewController]) {
        let controller = SegmentedPagerViewController(viewControllers: controllers)
        self.addChild(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        segmentedController = controller
    }
    
    private func setupContraints() {
        guard let view = segmentedController?.view else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
