//
//  MainTBVC.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/06.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit

class MainTBVC : UITabBarController, CustomTabBarDataSource, CustomTabBarDelegate{
    public var customTabBar : CustomTabBar? = nil
    override func viewDidLoad() {
        self.tabBar.isHidden = true
        
        customTabBar = CustomTabBar(frame: self.tabBar.frame)
        customTabBar?.datasource = self
        customTabBar?.delegate = self
        customTabBar?.setup()
        
        self.view.addSubview(customTabBar!)

    }
    // MARK: - CustomTabBarDataSource
    
    func tabBarItemsInCustomTabBar(tabBarView: CustomTabBar) -> [UITabBarItem] {
        return tabBar.items!
    }
    func didSelectViewController(tabBarView: CustomTabBar, atIndex index: Int) {
        self.selectedIndex = index
    }

}
