//
//  Utilities.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/02.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    let API_Root : String = "https://test-itrustyouservices.azurewebsites.net"
    
    public func getSignUpUrl() -> String {
        return API_Root+"/api/SignUp/SignUpCredentials/"
    }
    
    public static func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
