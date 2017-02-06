//
//  VSORequests.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/05.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import Alamofire
import QorumLogs


class VSORequest{
    
    //Get User Profile
    static let headers: HTTPHeaders = [
        "Authorization" : "Bearer "+VSO_API_Manager.sharedInstance.OAuthToken!
    ]
    static let APIRoot : String = "https://app.vssps.visualstudio.com/_apis"
    //API CALLS
    class func getUserProfile(completionHandler:@escaping (_ success : [String: Any]?, _ error: Error?)->Void) -> Void{
        QL1("Get User Profile")
        let path = APIRoot+"/profile/profiles/me?api-version=1.0"
        QL1(headers)
        VSO_API_Manager.sharedInstance.alamofireManager().request(path, headers : headers)
            .responseJSON{ response in
                if response.error != nil
                {
                    if let errcode = (response.response?.statusCode)! as Int?, errcode == 203{
                        QL1("Token expired")
                        //TODO: Fix this
                        //VSO_API_Manager.sharedInstance.refreshToken()
                        //self.getUserProfile(completionHandler: completionHandler)
                    }
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the user's profile")
                    //completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                    }
                }
                QL1(response)
            }.responseString { response in
               // print("Response String: \(response.result.value)")
            }
    }
    class func getUserAccounts(memberId:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("Get User Profile")
        let path = APIRoot+"/Accounts?memberId="+memberId+"&api-version=1.0"
        QL1(headers)
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the user's profile")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
                QL1(response)
            }
        
    }
    class func getAccountTeamProjects(accountName:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("Get User Profile")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/projects?api-version=1.0"
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the user's profile")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
                QL1(response)
        }
        
    }
    
}
