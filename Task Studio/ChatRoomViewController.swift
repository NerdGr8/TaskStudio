//
//  ChatRoomViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/27.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import JSQMessagesViewController
import QorumLogs

class ChatRoomViewController: JSQMessagesViewController {
    public var chatRoom : Int = 0
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var messages = [JSQMessage]()
    var tbc : MainTBVC? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserAccount
        let realm = try! Realm()
        let queries = realm.objects(UserAccount.self)
        print(queries)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tbc = self.tabBarController as? MainTBVC
        tbc?.customTabBar?.isHidden = true
        // messages from someone else
        addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
        // messages sent from local sender
        addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
        addMessage(withId: senderId, name: "Me", text: "I like to run!")
        VSORequest.getChatRoomMessages(accountName: "appfaqtoryza", roomId: chatRoom) { (response, error) in
            QL1(response)
            //VSOChatMessage
        }
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        tbc?.customTabBar?.isHidden = false
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
       // let itemRef = messageRef.childByAutoId() // 1
        /*var messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        */
        VSORequest.postChatRoomMessage(accountName: "appfaqtoryza", roomId: chatRoom, message: text) { (response, error) in
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()
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
