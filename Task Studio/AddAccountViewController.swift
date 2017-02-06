//
//  AddAccountViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/03.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import QorumLogs

class AddAccountViewController : UIViewController{
    
    @IBAction func AddAccount(_ sender: UIButton) {
        VSO_API_Manager.sharedInstance.refreshToken(completionHandler: { refreshed in
            
            QL2(refreshed)

            if refreshed == true{
                self.loadInitialData()
            }
            else{
                VSO_API_Manager.sharedInstance.startOAuth2Login()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "loadingOAuthToken")
        if (!defaults.bool(forKey: "loadingOAuthToken"))
        {
            QL1("You can load Data!")
            loadInitialData()
        }
        else{
            //View is still loadingAuthKey
            defaults.set(false, forKey: "loadingOAuthToken")
            QL2(defaults.bool(forKey: "loadingOAuthToken"))
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func loadInitialData()
    {
        if (!VSO_API_Manager.sharedInstance.hasOAuthToken())
        {
            VSO_API_Manager.sharedInstance.OAuthTokenCompletionHandler = {
                (error) -> Void in
                if let receivedError = error
                {
                    QL1("Received Error")
                    QL1(receivedError)
                    // TODO: handle error
                    // TODO: issue: don't get unauthorized if we try this query
                    //VSO_API_Manager.sharedInstance.startOAuth2Login()
                    return
                }
                else
                {
                    QL1("Received No Error")
                    VSORequest.getUserProfile(completionHandler:self.handleResponse)                }
            }
            VSO_API_Manager.sharedInstance.startOAuth2Login()
        }
        else
        {
            VSORequest.getUserProfile(completionHandler:self.handleResponse)
        }
    }
    func handleResponse(json: [String: Any]?, error: Error?){
        QL1("Handling response")
        if let responseJSON = json{
            let user = VsoUserAccount()
            user.displayName = responseJSON["displayName"] as! String
            user.emailAddress = responseJSON["emailAddress"] as! String
            user.id = responseJSON["id"] as! String
            
            // Get the default Realm
            let realm = try! Realm()
            // You only need to do this once (per thread)
            try! realm.write {
                realm.add(user,update: true)
            }
            //Get User Accounts
            VSORequest.getUserAccounts(memberId: user.id, completionHandler: { results, error in
                QL1(results as Any)
                if error == nil{
                    
                    if let accs = results?["count"] as? Int, accs <= 0{
                        QL1("You currently dont have any Visual Studio Online accounts")
                    }
                    do {
                        if let data = results,
                            let accounts = data["value"] as? [[String: Any]] {
                            for account in accounts {
                                let _account = VSOAccount()
                                _account.accountId = (account["accountId"] as? String)!
                                _account.accountName = (account["accountName"] as? String)!
                                _account.accountOwner = (account["accountOwner"] as? String)!
                                _account.accountUri = (account["accountUri"] as? String)!
                                _account.accountType = (account["accountType"] as? String)!
                                _account.accountStatus = (account["accountStatus"] as? String)!
                                _account.organizationName = (account["organizationName"] as? String)!
                                QL1(_account.accountName)
                                try! realm.write {
                                    realm.add(_account,update: true)
                                }
                                QL1("Getting Team Projects")
                                VSORequest.getAccountTeamProjects(accountName: _account.accountName, completionHandler: { projects, error in
                                    QL1(projects as Any)
                                    if error == nil{
                                        if let p = projects,
                                            let px = p["value"] as? [[String: Any]] {
                                            for x in px {
                                                let _project = VSOProject()
                                                _project.id = x["id"] as! String
                                                _project.name = x["name"] as! String
                                                _project.state = x["state"] as! String
                                                _project.url = x["url"] as! String
                                                QL1(x["name"] as Any)
                                                try! realm.write {
                                                    realm.add(_project,update: true)
                                                }
                                            }
                                            //Done Lets Go To Tab viewDidLoad
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "MainTBVC") as! MainTBVC
                                            self.navigationController?.pushViewController(vc, animated: true)
                                            
                                        }
                                    }
                                    else{
                                        QL1("VSORequest.getAccountTeamProjects Error")
                                    }
                                })
                            }
                        }
                    }
                }
                else{
                    QL1(error as Any)
                }
            })
            /*
             // Add to the Realm inside a transaction
             let predicate = NSPredicate(format: "id == %@", responseJSON["id"] as! String)
             let results = realm.objects(VsoAccount.self).filter(predicate)
             if results.count < 0 {
             print("New Account")
             
             }*/
            
        }
    }
}
