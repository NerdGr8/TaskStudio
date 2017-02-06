//
//  LogoView.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/02.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit

public class SnakeView: UIView {
    var label:UILabel!
    var button:UIButton!
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        
        label = UILabel(frame: CGRect(x: 12, y: 8, width: self.frame.size.width-90, height: 50))
        label.text = "Connection error please try again later!!"
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(label)
        
        button = UIButton(frame: CGRect(x: self.frame.size.width-87, y: 8, width: 86, height: 50))
        button.setTitle("OK", for: UIControlState.normal)
        button.setTitleColor(UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0), for: UIControlState.normal)
        button.addTarget(self, action: Selector(("hideSnackBar:")), for: UIControlEvents.touchUpInside)
        self.addSubview(button)
    }
    func hideSnackBar(sender: UIButton) {
        // Do whatever you need when the button is pressed
        self.removeFromSuperview()
    }
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateData(title:String){
        self.label.text = title
    }
    
}
