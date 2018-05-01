//
//  Utlities.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/07.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import Alamofire
/*
 repo.pushedAt = Date(fromString: pushedAt,
 format: .iso8601(.DateTimeSec)).timeIntervalSinceReferenceDate
 (inputFormat: "yyyy.MM.dd'T'HH:mm:ss:SSS:Z", outputFormat: "dd MMM HH:mm")
 */
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    func showAlert(title: String = "Oops!", message: String, isModal : Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        if isModal {
            show(alertController, sender: nil)
            return
        }
        topMostController().present(alertController, animated: true, completion: nil)
    }
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    func firstCharacterUpperCase() -> String
    {
        if let firstCharacter = characters.first, characters.count > 0
        {
            return replacingCharacters(in: startIndex ..< index(after: startIndex), with: String(firstCharacter).uppercased())
        }
        
        return self
    }
    func URLEncodedString() -> String? {
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString
    }
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
    func toDateTime() -> NSDate
    {
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-ddThh:mm:ss.SSSSxxx"
        
        //Parse into NSDate
        let dateFromString : NSDate = dateFormatter.date(from: self)! as NSDate
        
        //Return Parsed Date
        return dateFromString
    }
    
}
protocol HasNumber {
    var integerValue: Int { get }
}
struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
//extension NSString:HasNumber{}
//extension NSNumber:HasNumber{}
struct TaskStudioSession {
    let orgName = "currentOrganizationName"
    let loadingOAuthToken = "loadingOAuthToken"
    let currentChatRoom = "currentChatRoom"
}
