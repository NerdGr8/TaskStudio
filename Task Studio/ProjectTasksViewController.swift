//
//  ProjectTasksViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/09.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import RealmSwift
import QorumLogs
import ChameleonFramework
import GradientLoadingBar

class ProjectTasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ShowsAlert{
    
    @IBOutlet weak var table: UITableView!
    //
    
    let cellIdentifier = "TaskCellIdentifier"
    var tableTasks = List<VSOTask>()
    var needsSync = false
    var queryID = ""
    // Get the default Realm
    var currentProject = ""
    var currentOrganisation = ""
    var realm : Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if needsSync == true {
            GradientLoadingBar.sharedInstance().show()
            setup()
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.title = currentProject
        // Do any additional setup after loading the view.
    }
    func setup() {
        realm = try! Realm()
        if let query = realm?.objects(VSOProjectQuery.self).filter(NSPredicate(format: "id == %@", queryID)).first{
            //self.table.reloadData()
            //QL1(cells.items.count)
            if let path = query._links.filter("key == 'wiql'").first{
                VSORequest.getTeamProjectTaskIDsFromQuery(queryWIQL: path.href, completionHandler: {json , error in
                    QL1(json)
                    if(error == nil){
                        print("We found some data yo")
                        //dump(json?["workItems"])
                        let tasksForQuery = List<VSOTask>()
                        let columnsForTasks = List<VSOColumn>()
                        if let columns = json?["columns"] as? [[String:String]]{
                            QL2("we found columns")
                            for c in columns {
                                //dump(c)
                                //QL2(c["name"])
                                let column = VSOColumn()
                                column.displayName = c["name"] as String!
                                column.referenceName = c["referenceName"] as String!
                                column.url = c["url"] as String!
                                columnsForTasks.append(column)
                            }
                        }
                        if let workItems = json?["workItems"] as? [[String:Any]]{
                            QL2("we found workItems")
                            for c in workItems{
                                //QL2(c)
                                let task = VSOTask()
                                task.id = ((c["id"] as! HasNumber!)?.integerValue)!
                                task.url = c["url"] as! String!
                                task.columns.append(objectsIn: columnsForTasks)
                                //task.ownerQuery.= query
                                tasksForQuery.append(task)
                            }
                        }
                        try!  self.realm?.write {
                            self.realm?.add(tasksForQuery,update: true)
                            query.setValue(tasksForQuery, forKey: "tasks")
                        }
                        //Done Now load the next View
                        //GET ALL TASKS and their ID's
                        // Query using an NSPredicate
                        let tasks : [String] = query.tasks.map{ return String($0.id)}
                        
                        QL2(tasks)
                        VSORequest.getTasksByID(accountName: self.currentOrganisation, project: self.currentProject, tasksID: tasks, completionHandler: { (result, error) in
                            QL2(result)
                            if let count = result?["count"] as Any?{
                                print("Count \(count)")
                            }
                            if let workItems = result?["value"] as? [[String:Any]]{
                                // QL2("we found workItems")
                                //QL1(workItems)
                                let vsoTasks = self.realm?.objects(VSOTask.self)
                                
                                for wi in workItems{
                                    if let id = wi["id"] as? NSNumber{
                                        dump(id)
                                        if let item = vsoTasks?.filter(NSPredicate(format: "id == %@", id as NSNumber)).first{
                                            do{
                                                try! self.realm?.write {
                                                    
                                                    item.setValue(wi["rev"], forKey: "rev")                                            //GET Fields value
                                                    if let fields = wi["fields"] as? [String:Any]{
                                                        print("we found the fields")
                                                        for f in fields {
                                                            //print("Field \(f.key)")
                                                            if f.key == "System.Title" {
                                                                item.setValue(f.value, forKey: "title")
                                                            }
                                                            if f.key == "System.State" {
                                                                item.setValue(f.value, forKey: "state")
                                                            }
                                                            if f.key == "System.Description" {
                                                                item.setValue(f.value, forKey: "taskDescription")
                                                            }
                                                            if f.key == "System.TeamProject" {
                                                                item.setValue(f.value, forKey: "teamProject")
                                                            }
                                                            if f.key == "System.AssignedTo" {
                                                                item.setValue(f.value, forKey: "assignedTo")
                                                            }
                                                            if f.key == "System.ChangedBy" {
                                                                item.setValue(f.value, forKey: "createdBy")
                                                            }
                                                            if f.key == "System.CreatedBy" {
                                                                item.setValue(f.value, forKey: "changedBy")
                                                            }
                                                            if f.key == "System.IterationPath" {
                                                                //item.setValue(wi["System.Title"], forKey: "priority")
                                                                item.setValue(f.value, forKey: "iterationPath")
                                                            }
                                                            if f.key == "System.WorkItemType" {
                                                                item.setValue(f.value, forKey: "workItemType")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            self.tableTasks.append(item)
                                            QL1(item)
                                        }
                                    }
                                    
                                }
                                DispatchQueue.main.async{
                                    QL1(self.tableTasks)
                                    self.table.reloadData()
                                }
                            }
                            //Parse Tasks into Object
                        })
                    }
                    else{
                        self.showAlert(message: "Error: \(error as? String)")
                        print("Error: \(error as? String)")
                    }
                    GradientLoadingBar.sharedInstance().hide()
                })
            }
            else{
                self.showAlert(message: "The current query doesnt have a WIQL")
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     TablViewDataSource
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = tableTasks.count
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        let item = tableTasks[indexPath.row]
        cell.textLabel?.textColor = UIColor.flatBlackDark
        cell.detailTextLabel?.textColor = UIColor.flatGray
        if item.state != nil{
            switch item.state as String! {
                case "Active" :
                    cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.flatBlue, thickness: 3)
                    break
                case "Closed" :
                    cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.flatRed, thickness: 3)
                    break
                case "New" :
                    cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.flatGray, thickness: 3)
                break
                case "Removed" :
                    cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.flatRedDark, thickness: 3)
                    break
                case "Resolved" :
                    cell.layer.addBorder(edge: UIRectEdge.left, color: UIColor.flatRed, thickness: 3)
                    break
                default:
                    break
            }
        }
        // Configure Cell
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.assignedTo
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = tableTasks[(indexPath as NSIndexPath).row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskDetailsViewController") as! TaskDetailsViewController
        vc.task = item
        self.show(vc, sender: self)
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
