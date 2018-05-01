//
//  ViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/01.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import Alamofire
import QorumLogs

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    var snakView: SnakeView!
    func handleResponse(json: [String: Any]){
        QL1(json)
        
        let message = json["Message"] as! String
        snakView.updateData(title: message);
        self.view.addSubview(snakView)
    }
    @IBAction func login(_ sender: Any) {
        if(txtUserName.text != "" && isValidEmail(emailString: txtUserName.text!) && txtPassword.text != ""){
           
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        snakView = SnakeView(frame: Utilities.CGRectMake(0 ,self.view.frame.size.height-66, self.view.frame.size.width, 66))
        // Do any additional setup after loading the view, typically from a nib.
        btnLogin.layer.cornerRadius = 23;
        txtUserName.layer.cornerRadius = 23;
        txtPassword.layer.cornerRadius = 23;
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

