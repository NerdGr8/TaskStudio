//
//  AddAccountWebViewVC.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/04/07.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import QorumLogs

class AddAccountWebViewVC: UIViewController, UIWebViewDelegate {
    var clientID = "84CAB7C3-3DE1-4A06-946B-28175BF0F933"
    @IBOutlet weak var webView: UIWebView!
    var isInitialRequest :Bool = true
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        
        // Set Center
        var center = self.view.center
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            center.y -= (navigationBarFrame.origin.y + navigationBarFrame.size.height)
        }
        activityIndicatorView.center = center
        
        self.view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        if Connectivity.isConnectedToInternet {
            print("Connected")
        } else {
            print("No Internet")
            self.showAlert(message: "Looks like you dont have connectivity :-(")
        }
        
        URLCache.shared.removeAllCachedResponses()
        // Delete any associated cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        activityIndicatorView.startAnimating()
        let qString:String = "?client_id="+clientID+"&response_type=Assertion&state=User1&scope=vso.chat_manage%20vso.dashboards%20vso.dashboards_manage%20vso.identity%20vso.notification_manage%20vso.profile_write%20vso.project_manage%20vso.release_manage%20vso.test_write%20vso.work_write&redirect_uri=https://tskstds"
        let authPath:String = "https://app.vssps.visualstudio.com/oauth2/authorize"+qString
        self.webView.loadRequest(URLRequest(url: URL(string: authPath)!))
        // Do any additional setup after loading the view.
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        let urlString: String = request.url!.absoluteString
        print("URL STRING : \(urlString) ")
        let UrlParts: [String] = urlString.components(separatedBy:"https://tskstds")
        
        if UrlParts.count > 1 && isInitialRequest == false{
            // do any of the following here
            VSO.sharedInstance.processOAuthStep1Response(url: request.url! as NSURL)
            VSO.sharedInstance.OAuthTokenCompletionHandler = {
                (error) -> Void in
                if let receivedError = error
                {
                    QL1("Received Error")
                    QL1(receivedError)
                    return
                }
                else
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController
                    self.show(vc, sender: self)
                    QL1("Received No Error")
                }
            }
            return false
        }
        isInitialRequest = false
        return true;
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    func webViewDidFinishLoad(_ webView: UIWebView){
        //RappleActivityIndicatorView.stopAnimation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
