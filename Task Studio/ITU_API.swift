//
//  ITU_API.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/02.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import Alamofire
import QorumLogs

class ITU_API {
    
     let API_Root = "https://test-itrustyouservices.azurewebsites.net"
    public func getSignUpUrl(username: String, password: String, deviceID: String, completion:@escaping ([String: Any])->Void) -> Void{
        
        let parameters: Parameters = [
            "Username": username,
            "Password": password,
            "DeviceID" : deviceID
            ]
        let headers: HTTPHeaders = [
                "ZUMO-API-VERSION": "2.0.0",
                "Accept": "application/json"
            ]

        let urlEndpoint = "https://test-itrustyouservices.azurewebsites.net/api/SignUp/SignUpCredentials/"
        
            Alamofire.request(urlEndpoint, method: .put, parameters : parameters, encoding: JSONEncoding.default, headers : headers)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    QL1("Error while fetching tags: \(String(describing: response.result.error))")
                    return
                }
                guard let responseJSON = response.result.value as? [String: Any] else {
                    QL1("Invalid tag information received from the service")
                    return
                }
                completion(responseJSON)
            }
    }
}

