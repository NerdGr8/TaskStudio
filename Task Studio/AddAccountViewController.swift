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
import GradientLoadingBar
import ChameleonFramework

class AddAccountViewController : UIViewController, ShowsAlert{
    
    @IBOutlet weak var tblAccounts: UITableView!
    @IBAction func AddAccount(_ sender: UIButton) {
        
        if (!VSO.sharedInstance.hasOAuthToken())
        {
            QL1("No AuthToken")
            VSO.sharedInstance.OAuthTokenCompletionHandler = {
                (error) -> Void in
                if let receivedError = error
                {
                    QL1("Received Error")
                    QL1(receivedError)
                    // TODO: handle error
                    // TODO: issue: don't get unauthorized if we try this query
                    //VSO.sharedInstance.startOAuth2Login()
                    return
                }
                else
                {
                    QL1("Received No Error")
                    VSORequest.getUserProfile(completionHandler:self.handleResponse)
                }
            }
            VSO.sharedInstance.startOAuth2Login()
        }
    }
    
    // Get the default Realm
    var realm : Realm?

    let textCellIdentifier = "AccountViewCell"
    let userAccounts : Results<VSOAccount> = {
        let r = try! Realm()
        return r.objects(VSOAccount.self)
    }()
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.tblAccounts.allowsSelection = true
        token = userAccounts.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tblAccounts else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(let results, let deletions, let insertions, let modifications):
                
                tableView.beginUpdates()
                
                //re-order repos when new pushes happen
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                
                //flash cells when repo gets more stars
                for row in modifications {
                    let indexPath = IndexPath(row: row, section: 0)
                    let account = results[indexPath.row]
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.textLabel?.textColor = UIColor.flatBlackDark
                    cell?.detailTextLabel?.textColor = UIColor.flatGray
                    cell?.textLabel?.text = account.accountName.firstCharacterUpperCase()
                    cell?.detailTextLabel?.text = account.accountUri
                }
                
                tableView.endUpdates()
                break
            case .error(let error):
                print(error)
                break
            }
        }
        //self.navigationItem.titleView = UIImageView.init(image: UImage("Images/splash_logo_1.png"))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        QL2("View will appear")
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "loadingOAuthToken")
        if (!defaults.bool(forKey: "loadingOAuthToken"))
        {
            QL1("You can load Data!")
            loadInitialData()
        }
        else{
            //View is still loadingAuthKey
            //defaults.set(false, forKey: "loadingOAuthToken")
            QL2(defaults.bool(forKey: "loadingOAuthToken"))
        }

    }
    func loadInitialData()
    {
        if(VSO.sharedInstance.hasOAuthToken())
        {   //SET UP WORKSPACE
            GradientLoadingBar.sharedInstance().show()
            VSORequest.getUserProfile(completionHandler:self.handleResponse)
            GradientLoadingBar.sharedInstance().hide()
        }
        else{
            //Check if we are coming from the Oauth call?
            QL1("No AuthToken / No Accont")
            VSO.sharedInstance.OAuthTokenCompletionHandler = {
                (error) -> Void in
                if let receivedError = error
                {
                    QL1("Received Error")
                    QL1(receivedError)
                    // TODO: handle error
                    // TODO: issue: don't get unauthorized if we try this query
                    //VSO.sharedInstance.startOAuth2Login()
                    return
                }
                else
                {
                    QL1("Received No Error, We must Launch or reload the Account List")
                    VSORequest.getUserProfile(completionHandler:self.handleResponse)
                }
            }
        }
    }
    func handleResponse(json: [String: Any]?, error: Error?){
        QL1("Handling response")
        if let responseJSON = json{
            let user = VsoUserAccount()
            user.displayName = responseJSON["displayName"] as! String
            user.emailAddress = responseJSON["emailAddress"] as! String
            user.id = responseJSON["id"] as! String
                        // You only need to do this once (per thread)
            try! realm?.write {
                realm?.add(user,update: true)
            }
            self.tblAccounts.reloadData()
            //Get User Accounts
            VSORequest.getUserAccounts(memberId: user.id, completionHandler: { results, error in
                QL1(results as Any)
                if error == nil{
                    
                    if let accs = results?["count"] as? Int, accs <= 0{
                        QL1("You currently dont have any Visual Studio Online accounts")
                        //self.showAlert(message: "You currently dont have any Visual Studio Online accounts")
                    }
                    do {
                        if let data = results,
                            let accounts = data["value"] as? [[String: Any]] {
                            for account in accounts {
                                let _account = VSOAccount()
                                _account.accountId = (account["accountId"] as? String)!
                                _account.accountName = (account["accountName"] as? String)!
                                _account.accountUri = (account["accountUri"] as? String)!
                                _account.accountType = (account["accountType"] as? String)
                                _account.accountStatus = (account["accountStatus"] as? String)
                                _account.organizationName = (account["organizationName"] as? String)
                                QL1(_account.accountName)
                                try! self.realm?.write {
                                    self.realm?.add(_account,update: true)
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
                                                _project.projectDescription = x["description"] as? String
                                                _project.url = x["url"] as! String
                                                _project.owner = _account
                                                QL1(x["name"] as Any)
                                                try!  self.realm?.write {
                                                    self.realm?.add(_project,update: true)
                                                }
                                            }
                                            //Done Lets Go To Tab viewDidLoad
                                            /*
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "MainTBVC") as! MainTBVC
                                            self.show(vc, sender: self)
                                            */
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
                    self.showAlert(message: error as! String)
                }
            })
        }
    }

}
extension AddAccountViewController : UITableViewDelegate{
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QL1("You selected cell #\(indexPath.row)!")
        let row = indexPath.row
        
        UserDefaults.standard.set((userAccounts[row].accountName), forKey : TaskStudioSession().orgName)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTBVC") as! MainTBVC
        self.show(vc, sender: self)
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // let the controller to know that able to edit tableView's row
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let deleteAction = UITableViewRowAction(style: .default, title: "Remove", handler: { (action , indexPath) -> Void in
            
            // Your delete code here.....
            QL2("Will delete")
        })
        deleteAction.backgroundColor = UIColor.flatRed
        
        return [deleteAction]
    }
}
extension AddAccountViewController : UITableViewDataSource{
    // MARK:  UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAccounts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.layer.cornerRadius = 4
        
        let row = indexPath.row
        cell.textLabel?.textColor = UIColor.flatBlackDark
        cell.detailTextLabel?.textColor = UIColor.flatGray
        cell.textLabel?.text = userAccounts[row].accountName.firstCharacterUpperCase()
        cell.detailTextLabel?.text = userAccounts[row].accountUri
        //cell
        
        return cell
    }
}
