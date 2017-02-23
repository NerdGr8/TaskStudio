//
//  TeamsPageViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/15.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit

class TeamsPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var VCArray : [UIViewController] = {
        return [self.VCInstance(name : "RoomsVC"),
                self.VCInstance(name : "MessagesVC"),
                self.VCInstance(name : "UsersVC")]
    }()
    
    private func VCInstance(name: String) ->  UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    var pageHeaders = ["Messages", "Rooms", "Users"]
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        if let firstVC = VCArray.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In terms of navigation direction. For example, for 'UIPageViewControllerNavigationOrientationHorizontal', view controllers coming 'before' would be to the left of the argument view controller, those coming 'after' would be to the right.
    // Return 'nil' to indicate that no more progress can be made in the given direction.
    // For gesture-initiated transitions, the page view controller obtains view controllers via these methods, so use of setViewControllers:direction:animated:completion: is not required.
   
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = VCArray.index(of: viewController) else{
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else{
            return VCArray.last
        }
        guard VCArray.count > previousIndex else {
            return nil
        }
        return VCArray[previousIndex]
    }
    
   
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
       
        guard let viewControllerIndex = VCArray.index(of: viewController) else{
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < VCArray.count else{
            return VCArray.first
        }
        guard VCArray.count > nextIndex else {
            return nil
        }
        return VCArray[nextIndex]
    }
    
    
    // A page indicator will be visible if both methods are implemented, transition style is 'UIPageViewControllerTransitionStyleScroll', and navigation orientation is 'UIPageViewControllerNavigationOrientationHorizontal'.
    // Both methods are called in response to a 'setViewControllers:...' call, but the presentation index is updated automatically in the case of gesture-driven navigation.
    //RETURNS The number of items reflected in the page indicator.
    public func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return VCArray.count
    }
    
    //RETURNS The selected item reflected in the page indicator.
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = VCArray.index(of: firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
    
}
