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
    static var headers: HTTPHeaders = [
        "Authorization" : "Bearer "+VSO.sharedInstance.OAuthToken!,
        "Accept": "application/json",
        "Accept-Encoding" : ""
    ]
    static let APIRoot : String = "https://app.vssps.visualstudio.com/_apis"
    //API CALLS
    class func getUserProfile(completionHandler:@escaping ([String: Any]?,Error?)->Void) -> Void{
        QL1("Get User Profile")
        let path = APIRoot+"/profile/profiles/me?api-version=1.0"
        QL1(headers)
        Alamofire.request(path, headers : headers)
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
    //WORTH ITEM QUERIES
    //TODO:Change Depth to 2
    class func getTeamProjectQueries(accountName:String, project:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("Get Project Queries")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/"+project.URLEncodedString()!+"/_apis/wit/queries?$depth=1&$expand=wiql&api-version=2.2"
        
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's Project Queries")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
        }
        
    }
    //TODO:
    //GET PROJECT TASKS
    class func getTeamProjectAllTasks(accountName:String, project:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("getTeamProjectAllTasks")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/"+project.URLEncodedString()!+"/_apis/wit/wiql?api-version=1.0"
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(path,method : .post , parameters: [:], headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's Project Queries")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
        }
    }
    //GET PROJECT TASK ID's From Query
    class func getTeamProjectTaskIDsFromQuery(queryWIQL:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("getTeamProjectAllTasks")
        let path = queryWIQL+"?api-version=1.0"
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's Project TASK IDS")
                    QL1(response.error)
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }
            .response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
        }
    }
    class func getTasksByID(accountName:String, project:String, tasksID:[String], completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("getTasksByID")
        let joinedIds = tasksID.joined(separator: ",")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/wit/WorkItems?ids="+joinedIds+"&api-version=1.0"
        QL1(path)
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the WORK ITEMS")
                    QL1(response.error)
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }
            .response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
        }
    }
    /*( Get all Tasks by sending a query manualy */
    class func getAllTasks(accountName:String, project:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("getTeamProjectAllTasks")
        let path = "https://"+accountName+".visualstudio.com/_apis/wit/wiql?api-version=4.1"
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        let parameters: Parameters = [
            "query": "Select [System.Id], [System.Title], [System.State] From WorkItems Where [System.WorkItemType] = 'Task' AND [State] <> 'Closed' AND [State] <> 'Removed' order by [Microsoft.VSTS.Common.Priority] asc, [System.CreatedDate] desc"
        ]
        Alamofire.request(path,method : .post , parameters: parameters, headers : headers)
            .responseJSON{ response in
                QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's Project Queries")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
        }
    }
    /*
 
        TEAMS
 
    */
    class func getChatTeamRooms(accountName:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("getChatTeamRooms")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/chat/rooms?api-version=1.0"
        QL1(VSO.sharedInstance.OAuthToken)
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Chat Rooms")
                    QL1(response.error)
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }
            .response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
                if response.response?.statusCode != 200{
                    QL4(response)
                }
        }
    }
    class func createChatTeamRoom(accountName:String, roomName:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("createChatTeamRoom")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/chat/rooms?api-version=1.0"
        let parameters: Parameters = [
            "name": roomName,
            "description" : "Awesome"
        ]
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(path,method : .post , parameters:parameters, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's ChatTeamRoom")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }.response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
                if response.response?.statusCode != 200{
                    QL4(response)
                }
        }

    }
    class func joinChatRoom(accountName:String, roomName:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("createChatTeamRoom")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/chat/rooms?api-version=1.0"
        let parameters: Parameters = [
            "name": roomName,
            "description" : "Awesome"
        ]
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(path,method : .post , parameters:parameters, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's ChatTeamRoom")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }.response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
                if response.response?.statusCode != 200{
                    QL4(response)
                }
        }
        
    }
    class func getChatRoomMessages(accountName:String, roomId:Int, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("createChatTeamRoom")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/chat/rooms/"+String(roomId)+"/messages?api-version=1.0"
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(path, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's getChatRoomMessages")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }.response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
                if response.response?.statusCode != 200{
                    QL4(response)
                }
        }
        
    }
    class func postChatRoomMessage(accountName:String, roomId:Int, message:String, completionHandler:@escaping ([String: Any]?, Error?)->Void) -> Void{
        QL1("postChatRoomMessage")
        let path = "https://"+accountName+".visualstudio.com/DefaultCollection/_apis/chat/rooms/"+String(roomId)+"/messages?api-version=1.0"
        let parameters: Parameters = [
            "content": message
        ]
        //POST REQUEST
        //Content-Type: application/json
        headers.updateValue("application/json", forKey: "Content-Type")
        Alamofire.request(path,method : .post , parameters:parameters, headers : headers)
            .responseJSON{ response in
                //QL1(response)
                if response.error != nil
                {
                    // TODO: parse out errors more specifically
                    //completionHandler(nil, error)
                    QL1("Ann error occured while fetching the Team's postChatRoomMessage")
                    completionHandler(nil, response.error)
                    return
                }
                else{
                    if let responseJSON = response.result.value as? [String: Any]{
                        completionHandler(responseJSON, nil)
                        return
                    }
                }
            }.response { response in
                print("Request Status Code: \(String(describing: response.response?.statusCode))")
                if response.response?.statusCode == 203{
                    QL4("Auth Token Expired")
                    VSO.sharedInstance.refreshToken(completionHandler: {_ in})
                }
                if response.response?.statusCode != 200{
                    QL4(response)
                }
        }
        
    }
}
