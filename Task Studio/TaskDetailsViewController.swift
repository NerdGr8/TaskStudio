//
//  TaskDetailsViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/14.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit

class TaskDetailsViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAssignedTo: UILabel!
    @IBOutlet weak var lblIterationPath: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblWorkItemType: UILabel!
    @IBOutlet weak var lblTaskID: UILabel!
    @IBOutlet weak var webViewDescription: UIWebView!
    
    var task : VSOTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = task?.title
        lblAssignedTo.text = (task?.assignedTo)?.padLeft(length: 2)
        lblIterationPath.text = (task?.iterationPath)?.padLeft(length: 2)
        
        lblState.text = (task?.state)?.padLeft(length: 2)
        lblWorkItemType.text = (task?.workItemType)?.padLeft(length: 2)
        lblTaskID.text = "\((task?.id)!)"
        // Do any additional setup after loading the view.
        
        webViewDescription.loadHTMLString((task?.taskDescription)!, baseURL: nil)
        webViewDescription.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontFamily =\"HelveticaNeue\"");
        //lblDescription.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
