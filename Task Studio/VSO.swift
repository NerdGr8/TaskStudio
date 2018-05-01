//
//  VSO_API_Manager.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/03.
//  Copyright © 2017 NM. All rights reserved.
//
import Foundation
import Alamofire
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
class VSO
{
    static let sharedInstance = VSO()
    let defaults = UserDefaults.standard
    var OAuthToken: String?
        {
        set
        {
            if let valueToSave = newValue
            {
                defaults.set(valueToSave, forKey: "token")
                defaults.set(false, forKey: "loadingOAuthToken") //We have a token now so loading is done
                 UserDefaults.standard.synchronize()
            }
            else if newValue == nil{
                //Trying to rest this account
                defaults.removeObject(forKey: "token")
            }
        }
        get
        {
            if let token = defaults.string(forKey: "token"){
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
                defaults.set(valueToSave, forKey: "refresh_token")
                UserDefaults.standard.synchronize()
            }
            else if newValue == nil{
                //Trying to rest this account
                defaults.removeObject(forKey: "refresh_token")
            }
        }
        get
        {
            if let refresh_token = defaults.string(forKey: "refresh_token"){
                QL2(refresh_token)
                return refresh_token
            }
            return nil
        }
    }
    
    var OAuthScope: String?
    let redirect_uri : String = "https://tskstds"
    var clientID: String = "84CAB7C3-3DE1-4A06-946B-28175BF0F933"
    var clientSecret: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im9PdmN6NU1fN3AtSGpJS2xGWHo5M3VfVjBabyJ9.eyJjaWQiOiI4NGNhYjdjMy0zZGUxLTRhMDYtOTQ2Yi0yODE3NWJmMGY5MzMiLCJjc2kiOiJhOGVjZTk5Ny00YzViLTQxNTYtYmM1Mi1mZTUzM2E0ODAyYWUiLCJuYW1laWQiOiJlY2VjNmFiMi02ZDg3LTQ4OGYtOWU4ZC1hYTdiMmJiZTBkNjIiLCJpc3MiOiJhcHAudnNzcHMudmlzdWFsc3R1ZGlvLmNvbSIsImF1ZCI6ImFwcC52c3Nwcy52aXN1YWxzdHVkaW8uY29tIiwibmJmIjoxNDg3NzUzMDAyLCJleHAiOjE2NDU1MTk0MDJ9.YfdMk2aNPWPlEhSk3DgS4aWpIeahgDov5hvYzAuYi0N5GquJic4-AofJo6mGNc7XzaofwvEKt8xG4FB5-2JriA1og5IFhkVcDwk5r7mT4uDp84krso4iKrcuSJsyXYBdR8GR60UUwUuzJpFWQMIjHxZZ9GLhAE-MCKBX1DpGWLG2E6PAyxzp8b50XYYRZCG5l0szBsapPPiDcavVI92cPAHQ7YSVzvgtcAlCwxojeno7ySkdtNBmzmGhMkShqWT7P05xabY9OoFLsjYM-VdSFrPBcBF1GEjklHMMW95T5p-10LmHIcXZ8hw8XmOvA3w2bsz7o3Iu7tI-hfz-VweeOg"
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
            //manager.retrier = OAuth2RequestRetry()
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
        QL2("Loading Step 1 Response")
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
                print(queryItem)
            }
        }
        else{
            QL2("Couldnt find query items")
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
                    
                    UserDefaults.standard.synchronize()
                    //self.OAuthScope = responseJSON["scope"] as! String?
                    QL1("AuthToken:\(String(describing: self.OAuthToken))")
                    
                    self.defaults.set(false, forKey: "loadingOAuthToken")
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
        }
        else{
            QL2("no code in URL that we launched with")
            defaults.set(false, forKey: "loadingOAuthToken")
        }
        
    }
    // MARK: - OAuth flow
    
    func startOAuth2Login()
    {
        let qString:String = "?client_id="+clientID+"&response_type=Assertion&state=User1&scope=vso.chat_manage%20vso.dashboards%20vso.dashboards_manage%20vso.identity%20vso.notification_manage%20vso.profile_write%20vso.project_manage%20vso.release_manage%20vso.test_write%20vso.work_write&redirect_uri=https://taskstudio.azurewebsites.net/app/auth"
        let authPath:String = "https://app.vssps.visualstudio.com/oauth2/authorize"+qString
        if let authURL:URL = URL(string: authPath)
        {
            defaults.set(true, forKey: "loadingOAuthToken")
            // do stuff with authURL
            UIApplication.shared.open(authURL)
        }
    }
    
    //REFRESH TOKEN
    func refreshToken(completionHandler:@escaping (Bool?)->Void)
    {
        
        //REALM CHECK
        if self.hasOAuthToken() || (self.OAuthRefreshToken != nil)
        {
            QL1("Refreshing token")
            let getTokenPath:String = "https://app.vssps.visualstudio.com/oauth2/token"
            let tokenParams = ["client_assertion_type" :"urn:ietf:params:oauth:client-assertion-type:jwt-bearer","redirect_uri": self.redirect_uri, "client_assertion": self.clientSecret, "assertion": self.OAuthRefreshToken!, "grant_type": "refresh_token"]
            let headers: HTTPHeaders = [
                "Content-type": "application/x-www-form-urlencoded"
            ]
            QL1(tokenParams)
            Alamofire.request(getTokenPath, method : .post , parameters: tokenParams, headers : headers)
                .responseJSON{ response in
                    QL1(response)
                    if response.error != nil{
                        QL4("Auth refresh error")
                    }
                    else{
                        // TODO: handle response to extract OAuth token
                        //print(response.result.value)
                        guard let responseJSON = response.result.value as? [String: Any] else {
                            QL1("Invalid token information received from the service")
                            completionHandler(false)
                            return
                        }
                        self.OAuthToken = responseJSON["access_token"] as! String?
                        self.OAuthRefreshToken = responseJSON["refresh_token"] as! String?
                                                //self.OAuthScope = responseJSON["scope"] as! String?
                        //print(responseJSON["access_token"])
                        QL1("New AuthToken:\(responseJSON["access_token"] as! String?)")
                        completionHandler(true)
                        return
                    }
            }
        }
        else{
            QL1("No Token yet")
            completionHandler(true)
        }
    }
}
