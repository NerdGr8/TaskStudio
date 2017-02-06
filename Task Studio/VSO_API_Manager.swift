//
//  VSO_API_Manager.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/03.
//  Copyright © 2017 NM. All rights reserved.
//
import Foundation
import Alamofire
import Locksmith
import QorumLogs

class OAuth2RequestRetry: RequestRetrier {
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 203 || response.statusCode == 401 {
            //Likely OAuth error
            QL1("Will retry request")
            //VSO_API_Manager.sharedInstance.refreshToken()
            completion(true, 1.0) // retry after 1 second
        } else {
            QL1("Will not retry request")
            completion(false, 0.0) // don't retry
        }
    }
}
class AccessTokenAdapter: RequestAdapter{
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if (urlRequest.url?.absoluteString.hasPrefix("https://app.vssps.visualstudio.com"))! {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
class VSO_API_Manager
{
    static let sharedInstance = VSO_API_Manager()
    var OAuthToken: String?
        {
        set
        {
            if let valueToSave = newValue
            {
                do {
                    try Locksmith.saveData(data: ["token": valueToSave], forUserAccount: "vso")
                }
                catch LocksmithError.duplicate {
                    // do something in reponse to Duplicate error
                    do {
                        try Locksmith.updateData(data: ["token": valueToSave], forUserAccount: "vso")
                        
                    } catch {
                        QL1(error)
                    }
                } catch {
                    // do something in reponse to any other error
                    QL1(error)
                }
            }
        }
        get
        {
            // try to load from keychain
            let dictionary = Locksmith.loadDataForUserAccount(userAccount: "vso")
            if let token =  dictionary?["token"] as? String {
                return token
            }
            return nil
        }
    }
    
    var OAuthRefreshToken: String?{
        set
        {
            if let valueToSave = newValue
            {
                do {
                    try Locksmith.saveData(data: ["refresh_token": valueToSave], forUserAccount: "vso")
                }
                catch LocksmithError.duplicate {
                    // do something in reponse to Duplicate error
                    do {
                        try Locksmith.updateData(data: ["refresh_token": valueToSave], forUserAccount: "vso")
                        
                    } catch {
                        QL1(error)
                    }
                } catch {
                    // do something in reponse to any other error
                    QL1(error)
                }
            }
        }
        get
        {
            // try to load from keychain
            let dictionary = Locksmith.loadDataForUserAccount(userAccount: "vso")
            if let token =  dictionary?["refresh_token"] as? String {
                return token
            }
            return nil
        }
    }
    var OAuthScope: String?
    let redirect_uri : String = "https://taskstudio.azurewebsites.net/app/auth"
    var clientID: String = "ED790B58-A3DD-4061-8E16-2DC7F4F4857A"
    var clientSecret: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im9PdmN6NU1fN3AtSGpJS2xGWHo5M3VfVjBabyJ9.eyJjaWQiOiJlZDc5MGI1OC1hM2RkLTQwNjEtOGUxNi0yZGM3ZjRmNDg1N2EiLCJjc2kiOiJmOTg0ZDc1ZS1hMjkyLTRlMzQtYTRhZC0wN2E0NDhiMTlkMDciLCJuYW1laWQiOiJlY2VjNmFiMi02ZDg3LTQ4OGYtOWU4ZC1hYTdiMmJiZTBkNjIiLCJpc3MiOiJhcHAudnNzcHMudmlzdWFsc3R1ZGlvLmNvbSIsImF1ZCI6ImFwcC52c3Nwcy52aXN1YWxzdHVkaW8uY29tIiwibmJmIjoxNDg2MTA5Njk5LCJleHAiOjE2NDM4NzYwOTl9.1D7HZQGdwtf8Yjh3odpx1SYgeweXGJBiiwWbIbQlTkYnn0yJ1tmgk1hUh5v_7K2jCSPpbRUhCVc9xUUFKKh9tMmhfHQG_3dl2Elsp6YL7J1GTkHw_zA-B3wpzlRyq4S1bdamZCAP6GycVPlVJaKvt9eYtZxp0NAVq_B0FplCxkej3Jh-ibrGYcfahKrZvkJGdue8bGSFq_2yOyzOuQFUWBX5OdWGEPMwVxKQZrMpnrGhWtKJ9i7FL3PyfyUURieb4TrbZu1Gycl9RlNylNz-AS_MMTmAI3lNncsBIe1QHmUnF6ICj_Hwy5lP9RFYSCFt6WmlhwKzpEOG7wWo5gRw7g"
    // handlers for the OAuth process
    // stored as vars since sometimes it requires a round trip to safari which
    // makes it hard to just keep a reference to it
    var OAuthTokenCompletionHandler:((NSError?) -> Void)?
    
    func alamofireManager() -> SessionManager
    {
        let manager = Alamofire.SessionManager.default
        if hasOAuthToken()
        {
            manager.adapter = AccessTokenAdapter(accessToken: OAuthToken!)
            manager.retrier = OAuth2RequestRetry()
        }
        return manager
    }
    init () {
        if hasOAuthToken()
        {
           
        }
    }
    func hasOAuthToken() -> Bool
    {
        if let token = self.OAuthToken
        {
            return !token.isEmpty
        }
        return false
    }
    func processOAuthStep1Response(url: NSURL)
    {
        let components = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems
        {
            for queryItem in queryItems
            {
                if (queryItem.name.lowercased() == "code")
                {
                    code = queryItem.value
                    break
                }
            }
        }
        if let receivedCode = code
        {
            let getTokenPath:String = "https://app.vssps.visualstudio.com/oauth2/token"
            let tokenParams = ["client_assertion_type" :"urn:ietf:params:oauth:client-assertion-type:jwt-bearer","redirect_uri": redirect_uri, "client_assertion": clientSecret, "assertion": receivedCode, "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer"]
            let headers: HTTPHeaders = [
                "Content-type": "application/x-www-form-urlencoded"
            ]
            Alamofire.request(getTokenPath, method : .post , parameters: tokenParams, headers : headers)
                .responseJSON{ response in
                    // TODO: handle response to extract OAuth token
                    //QL1(response.result.value)
                    guard let responseJSON = response.result.value as? [String: Any] else {
                        QL1("Invalid token information received from the service")
                        return
                    }
                    self.OAuthToken = responseJSON["access_token"] as! String?
                    self.OAuthRefreshToken = responseJSON["refresh_token"] as! String?
                    //self.OAuthScope = responseJSON["scope"] as! String?
                    //QL1("AuthToken:"+self.OAuthToken! as Any)
                    
            }
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "loadingOAuthToken")
            if self.hasOAuthToken()
            {
                if let completionHandler = self.OAuthTokenCompletionHandler
                {
                    completionHandler(nil)
                }
            }
            else
            {
                if let completionHandler = self.OAuthTokenCompletionHandler
                {
                    let nOAuthError = NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                    completionHandler(nOAuthError)
                }
            }
        }
        else{
            // no code in URL that we launched with
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "loadingOAuthToken")
        }
        
    }
    // MARK: - OAuth flow
    
    func startOAuth2Login()
    {
        let qString:String = "?client_id=ED790B58-A3DD-4061-8E16-2DC7F4F4857A&response_type=Assertion&state=User1&scope=vso.dashboards%20vso.identity%20vso.work_write&redirect_uri=https://taskstudio.azurewebsites.net/app/auth"
        let authPath:String = "https://app.vssps.visualstudio.com/oauth2/authorize"+qString
        if let authURL:URL = URL(string: authPath)
        {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "loadingOAuthToken")
            // do stuff with authURL
            UIApplication.shared.open(authURL)
        }
    }
    
    //REFRESH TOKEN
    func refreshToken(completionHandler:@escaping (Bool?)->Void)
    {
        if hasOAuthToken()
        {
            QL1("Refreshing token")
            let getTokenPath:String = "https://app.vssps.visualstudio.com/oauth2/token"
            let tokenParams = ["client_assertion_type" :"urn:ietf:params:oauth:client-assertion-type:jwt-bearer","redirect_uri": redirect_uri, "client_assertion": clientSecret, "assertion": self.clientSecret, "grant_type": self.OAuthRefreshToken]
            let headers: HTTPHeaders = [
                "Content-type": "application/x-www-form-urlencoded"
            ]
            Alamofire.request(getTokenPath, method : .post , parameters: tokenParams, headers : headers)
                .responseJSON{ response in
                    // TODO: handle response to extract OAuth token
                    //print(response.result.value)
                    guard let responseJSON = response.result.value as? [String: Any] else {
                        QL1("Invalid token information received from the service")
                        completionHandler(true)
                        return
                    }
                    self.OAuthToken = responseJSON["access_token"] as! String?
                    self.OAuthRefreshToken = responseJSON["refresh_token"] as! String?
                    //self.OAuthScope = responseJSON["scope"] as! String?
                    QL1("New AuthToken:\(responseJSON["access_token"])")
                    completionHandler(true)
                    return
            }
        }
        else{
            QL1("No Token yet")
            completionHandler(true)
        }
    }
}
