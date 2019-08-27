//
//  SegmentedPagerViewController.swift
//  EvercheckWallet
//
//  Created by Felipe Correa on 6/4/19.
//  Copyright © 2019 CE Broker. All rights reserved.
//

import UIKit
import EmeraldIOS

class SegmentedPagerViewController: UIViewController {
    
    private enum Constants {
        static let empty = ""
        static let zero = 0
        static let one = 1
        static let segmentedBarHeight: CGFloat = 50.0
    }
    
    private var segmentedBar: EmeraldSegmentedBar
    
    private lazy var pagerViewController: UIPageViewController = {
        let viewCtrl = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll,
                                            navigationOrientation: .horizontal,
                                            options: nil)
        return viewCtrl
    }()
    
    private var viewControllers: [UIViewController] = []
    
    func setViewControllers(_ values: [UIViewController]) {
        self.viewControllers = values
    }
    
    func setSegmentedBarTheme(_ theme: EmeralSegmentedBarStyle) {
        segmentedBar.setTheme(theme)
    }
    
    init(viewControllers: [UIViewController]) {
        let titles = viewControllers.map { $0.title ?? Constants.empty }
        segmentedBar = EmeraldSegmentedBar(titles: titles)
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContraints()
        segmentedBar.delegate = self
        pagerViewController.dataSource = self
        pagerViewController.delegate = self
        moveToIndex(Constants.zero)
    }
    
    private func setupUI() {
        self.view.backgroundColor = EmeraldTheme.whiteColor
        self.view.addSubview(segmentedBar)
        self.addChild(pagerViewController)
        self.view.addSubview(pagerViewController.view)
    }
    
    private func setupContraints() {
        segmentedBar.translatesAutoresizingMaskIntoConstraints = false
        segmentedBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        segmentedBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        segmentedBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        segmentedBar.heightAnchor.constraint(equalToConstant: Constants.segmentedBarHeight).isActive = true
        
        guard let pagerView = pagerViewController.view else { fatalError("Something went wrong with the pagerVC")}
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.topAnchor.constraint(equalTo: segmentedBar.bottomAnchor).isActive = true
        pagerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pagerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pagerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        pagerViewController.didMove(toParent: self)
    }
    
    private func moveToIndex(_ index: Int) {
        let direction: UIPageViewController.NavigationDirection = index < currentPage() ? .reverse : .forward
        let viewCtrl = viewControllers[index]
        pagerViewController.setViewControllers([viewCtrl],
                                               direction: direction,
                                               animated: true,
                                               completion: nil)
    }
    
    private func currentPage() -> Int {
        if let firstViewController = pagerViewController.viewControllers?.first,
            let index = viewControllers.firstIndex(of: firstViewController) {
            return index
        } else {
            return Constants.zero
        }
    }
}

extension SegmentedPagerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - Constants.one
        guard previousIndex >= Constants.zero else {
            return nil
        }
        guard viewControllers.count > previousIndex else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + Constants.one
        let orderedViewControllersCount = viewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return viewControllers[nextIndex]
    }
}

extension SegmentedPagerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let index = currentPage()
            segmentedBar.moveSelectionBar(to: index)
        }
    }
}

extension SegmentedPagerViewController: EmeraldSegmentedBarActionable {
    func segmentedBar(_ bar: EmeraldSegmentedBar, didTapItemAt index: Int, with title: String) {
        moveToIndex(index)
    }
}
