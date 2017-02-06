//
//  RegisterViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/03.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import QorumLogs

class RegisterViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    var snakView: SnakeView!
    func handleResponse(json: [String: Any]){
        QL1(json)
        let message = json["Message"] as! String
        
        snakView.updateData(title: message);
        self.view.addSubview(snakView)
    }
    @IBAction func register(_ sender: Any) {
        if(txtUserName.text != "" && isValidEmail(emailString: txtUserName.text!) && txtPassword.text != ""){
            ITU_API().getSignUpUrl(username: txtUserName.text!, password: txtPassword.text!, deviceID: "28362638320236283", completion:handleResponse)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        snakView = SnakeView(frame: Utilities.CGRectMake(0 ,self.view.frame.size.height-66, self.view.frame.size.width, 66))
        // Do any additional setup after loading the view, typically from a nib.
        btnRegister.layer.cornerRadius = 4;
        txtUserName.layer.cornerRadius = 4;
        txtPassword.layer.cornerRadius = 4;
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func DismissKeyboard(){
        self.view.endEditing(true)
    }
    func isValidEmail(emailString:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
}
