//
//  LMPageViewController.swift
//  LMViews
//
//  Created by Máthé Levente on 2017. 11. 27..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

open class LMPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var pages = [UIViewController]()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        setPages()
    }
    
    @IBInspectable
    open var pageIds: String = ""
    
    @IBInspectable
    open var storyboardName: String = ""
    
    private func setPages() {
        let pageIDStrings: [String] = pageIds.split(separator: ",").map({ return String($0) })
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        for id in pageIDStrings {
            let page = storyboard.instantiateViewController(withIdentifier: id)
            pages.append(page)
        }
        if pages.count > 0 {
            setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        }
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = pages.index(of: viewController) else {
            return nil
        }
        let next = current - 1
        if next < 0 {
            return nil
        }
        return pages[next]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = pages.index(of: viewController) else {
            return nil
        }
        let next = current + 1
        if next >= pages.count {
            return nil
        }
        return pages[next]
    }
}
