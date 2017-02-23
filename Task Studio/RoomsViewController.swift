//
//  RoomsViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/15.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit

import RealmSwift
import QorumLogs
import ChameleonFramework
import GradientLoadingBar
class RoomsViewController: UIViewController {
    
    @IBOutlet weak var newChatRoom: UIButton!
    @IBAction func createChatRoom(_ sender: Any) {
        doAlertControllerDemo()
        
    }
    let userAccounts : Results<VSOAccount> = {
        let r = try! Realm()
        return r.objects(VSOAccount.self)
    }()
    var token: NotificationToken?
    var currentOrganisation : String = ""
    
    func doAlertControllerDemo() {
        
        var inputTextField: UITextField?;
        
        let chatRoomNamePrompt = UIAlertController(title: "New Chat room", message: "Create a new chat room", preferredStyle: UIAlertControllerStyle.alert);
        
        chatRoomNamePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            
            let entryStr : String = (inputTextField?.text)!
            
            print("BOOM! I received '\(entryStr)'")
            if entryStr.isEmpty != true{
                VSORequest.createChatTeamRoom(accountName: self.currentOrganisation, roomName: entryStr, completionHandler: { (response, error) in
                    QL1(response)
                })
            }
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
        
        
        return;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        currentOrganisation = UserDefaults.standard.string(forKey: TaskStudioSession().orgName)!
        getTeamRooms(acountName:currentOrganisation)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTeamRooms(acountName : String) -> Void {
        VSORequest.getChatTeamRooms(accountName: acountName) { (response, error) in
            QL1(response)
            //
            if let roomsJson = response?["value"] as? [[String: Any]] {
                for room in roomsJson {
                    let _room = VSOChatTeam()
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
    
}
