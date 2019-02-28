//
//  RoomsViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/15.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import QorumLogs
import ChameleonFramework
import GradientLoadingBar
class RoomsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var newChatRoomName: UITextField!
    @IBOutlet weak var newChatRoom: UIButton!
    @IBAction func createChatRoom(_ sender: Any) {
        doAlertControllerDemo()
    }
    
    let textCellIdentifier = "ChatRoomViewCell"
    var realm : Realm?
    let chatRooms : Results<VSOChatTeam> = {
        let r = try! Realm()
        return r.objects(VSOChatTeam.self)
    }()
    
    var user : VsoUserAccount?
    var token: NotificationToken?
    var currentOrganisation : String = ""
    
    func doAlertControllerDemo() {
        let entryStr : String = (newChatRoomName?.text)!
        
        if entryStr.isEmpty != true{
            VSORequest.createChatTeamRoom(accountName: self.currentOrganisation, roomName: entryStr, completionHandler: { (response, error) in
                QL1(response)
            })
        }
        /*
        var inputTextField: UITextField?;
        
        let chatRoomNamePrompt = UIAlertController(title: "New Chat room", message: "Create a new chat room", preferredStyle: UIAlertControllerStyle.alert);
        
        chatRoomNamePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            
            
            //self.doAlertViewDemo(); //do again!
        }));
        chatRoomNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("done");
        }));
        
        
        chatRoomNamePrompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Chat room name"     /* true here for pswd entry */
            inputTextField = textField
        });
        
        
        self.present(chatRoomNamePrompt, animated: true, completion: nil);
        
        */
        return;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        currentOrganisation = UserDefaults.standard.string(forKey: TaskStudioSession().orgName)!
        /*
        getTeamRooms(acountName:currentOrganisation)
        user = (realm?.objects(VsoUserAccount.self).first)!*/
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTeamRooms(acountName : String) -> Void {
        VSORequest.getChatTeamRooms(accountName: acountName) { (response, error) in
            QL1(response)
            
            if let roomsJson = response?["value"] as? [[String: Any]] {
                for room in roomsJson {
                    //QL1(room["lastActivity"] as? String)
                    let _room = VSOChatTeam()
                    let _creator = VSOUser()
                    _room.name = room["name"] as! String
                    _room.hasAdminPermissions = (room["hasAdminPermissions"] as! HasNumber).integerValue
                    _room.hasReadWritePermissions = (room["hasReadWritePermissions"] as! HasNumber).integerValue
                    //_room.lastActivity = ((room["lastActivity"] as! String).toDate(format: "dd MMM HH:mm")?.timeIntervalSinceNow)!
                    _room.lastActivity = room["lastActivity"] as! String

                    _room.id = (room["id"] as! HasNumber).integerValue
                    _room.roomDescription = room["description"] as! String
                    if let ca = room["createdBy"] as? [String:Any]{
                        _creator.id = ca["id"] as! String
                        _creator.displayName = ca["displayName"] as! String
                        _creator.imageUrl = ca["imageUrl"] as? String
                        _creator.url = ca["url"] as? String
                    }
                    _room.createdBy = _creator
                    
                    try!  self.realm?.write {
                        self.realm?.add(_room,update: true)
                    }
                    QL1(room);
                }
            }
            

        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK:  UITableViewDelegate Methods
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QL1("You selected cell #\(indexPath.row)!")
        let row = indexPath.row
        
        UserDefaults.standard.set((chatRooms[row].id), forKey : TaskStudioSession().currentChatRoom)
        UserDefaults.standard.synchronize()
         
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        vc.title = chatRooms[row].name
        //self.show(vc, sender: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK:  UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.layer.cornerRadius = 4
        
        let row = indexPath.row
        cell.textLabel?.textColor = UIColor.flatBlackDark
        cell.detailTextLabel?.textColor = UIColor.flatGray
        cell.textLabel?.text = chatRooms[row].name.firstCharacterUpperCase()
        cell.detailTextLabel?.text = chatRooms[row].lastActivity
        if let url = chatRooms[row].createdBy?.imageUrl {
            cell.imageView?.kf.setImage(with:  URL(string: url), options: [.transition(.fade(0.2))])
        }
        //cell
        
        return cell
    }

}
