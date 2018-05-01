//
//  CustomTabBarItem.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/23.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit

class CustomTabBarItem: UIView {
    
    var iconView: UIImageView!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(item: UITabBarItem) {
        /*
        guard let image = item.image else {
            image
        }
        */
        var image = TaskStudioStyleKit.imageOfSpeech_bubble_25
        if item.title == "Work" {
            image = TaskStudioStyleKit.imageOfTasks_25
        }
        else if item.title == "Teams" {
            image = TaskStudioStyleKit.imageOfSpeech_bubble_25
        }
        else if item.title == "Settings" {
            image = TaskStudioStyleKit.imageOfSettings_25
        }
        // create imageView centered within a container
        iconView = UIImageView(frame: CGRect(x: (self.frame.width-image.size.width)/2, y: (self.frame.height-image.size
            .height)/2, width: self.frame.width, height: self.frame.height))
        
        iconView.image = image
        iconView.sizeToFit()
        
        self.addSubview(iconView)
    }
    
}
