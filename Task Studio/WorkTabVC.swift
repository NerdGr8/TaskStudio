//
//  WorkTabVC.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/06.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import QorumLogs
import ChameleonFramework
import GradientLoadingBar

class WorkTabVC : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var currentOrganisation : String?
    @IBOutlet weak var lblTitle: UILabel!
    
    let cellIdentifier = "ProjectCellIdentifier"
    var organisationProjects : Results<VSOProject>?
    
    // Get the default Realm
    var realm : Realm?
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        currentOrganisation = UserDefaults.standard.string(forKey: TaskStudioSession().orgName)
        if currentOrganisation != nil {
            organisationProjects = realm?.objects(VSOProject.self).filter(NSPredicate(format: "url CONTAINS %@", currentOrganisation!))
        }
        self.automaticallyAdjustsScrollViewInsets = false
        QL1(organisationProjects)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesNavigationBarHairline = true
        lblTitle.tintColor = UIColor.flatBlackDark
        self.navigationController?.navigationBar.backgroundColor = UIColor.white        //view.addSubview(logoImage)
        self.navigationController?.navigationBar.topItem?.titleView = UIImageView(image: TaskStudioStyleKit.imageOfIcon_titleImage40)
    }
    
    /*
        TablViewDataSource
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = (organisationProjects?.count)! as Int
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        let project = organisationProjects?[indexPath.row]
        cell.textLabel?.textColor = UIColor.flatBlackDark
        cell.detailTextLabel?.textColor = UIColor.flatGray
        // Configure Cell
        cell.textLabel?.text = project?.name
        cell.detailTextLabel?.text = project?.projectDescription
        return cell
    }
    func getLinks(links : [String:Any])->List<VSOLink>{
        let _links = List<VSOLink>()
        for l in links{
            let link = VSOLink()
            link.key = l.key
            if let _l = l.value as? [String:String]{
                link.href = _l["href"]!
                QL2(_l["href"]!)

            }
            _links.append(link)
        }
        return _links
    }
    func parseProjectQueries(items : [[String:Any]], parentProject : VSOProject?, parentQuery : VSOProjectQuery?) -> List<VSOProjectQuery>{
        //var dateString = "2014-08-25T16:29:39.923Z"
        //var dateFormatter = NSDateFormatter()
        // this is imporant - we set our input date format to match our input string
        //dateFormatter.dateFormat = "dd-MM-yyyy"
        let _children = List<VSOProjectQuery>()
        
        for c in items{
            let item = VSOProjectQuery()
            let c_createdBy = VSOUser()
            let c_lastModifiedBy = VSOUser()
            //Set Author
            if let ca = c["createdBy"] as? [String:Any]{
                c_createdBy.id = ca["id"] as! String
                c_createdBy.displayName = ca["name"] as! String
            }
            //Set Modified
            if let cm = c["lastModifiedBy"] as? [String:Any]{
                c_lastModifiedBy.id = cm["id"] as! String
                c_lastModifiedBy.displayName = cm["name"] as! String
            }
            item.id = c["id"] as! String
            item.name = c["name"] as! String
            item.path = c["path"] as! String
            item.createdBy = c_createdBy
            item.createdDate = DateFormatter().date(from: (c["createdDate"] as! String)) as NSDate?
            item.lastModifiedBy = c_lastModifiedBy
            item.lastModifiedDate = DateFormatter().date(from: (c["lastModifiedDate"] as! String)) as NSDate?
            
            item.isPublic.value = (c["isPublic"] as? HasNumber)?.integerValue
            item.isFolder.value = (c["isFolder"] as? HasNumber)?.integerValue
            item.hasChildren.value = (c["hasChildren"] as? HasNumber)?.integerValue
            
            if (c["hasChildren"] as? HasNumber)?.integerValue == 1{
                if let ci = c["children"] as? [[String: Any]]{
                   let b = self.parseProjectQueries(items: ci, parentProject: parentProject, parentQuery : item)
                    item.children.append(objectsIn: b)
                }
            }
            if let l = c["_links"] as? [String:Any]{
                item._links.append(objectsIn : self.getLinks(links:l))
            }
            
            item.url = c["url"] as! String
            item.parentProject = parentProject
            _children.append(item)
        }
        return _children

    }
    //Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QL1("You selected cell #\(indexPath.row)!")
        let row = indexPath.row
        
       // QL1(organisationProjects?[row])
        let _parentProject = organisationProjects?[row]
        var hasTasks : Bool = false
        var hasQueries: Bool = false
        GradientLoadingBar.sharedInstance().show()
        QL1((organisationProjects?[row].owner?.accountName)!)
        //GET PROJECT QUERIES
        VSORequest.getTeamProjectAllTasks(accountName: (organisationProjects?[row].owner?.accountName)!, project: (organisationProjects?[row].name)!, completionHandler: {tasks , error in
            QL1(tasks as Any)
            hasTasks = ((tasks?.count)! > 0)
        })
        VSORequest.getTeamProjectQueries(accountName: (organisationProjects?[row].owner?.accountName)!, project: (organisationProjects?[row].name)!, completionHandler: {queries , error in
            QL1(queries)
            if error == nil {
                if let p = queries,
                    let px = p["value"] as? [[String: AnyObject]] {
                    hasQueries = (px.count>0)
                    for x in px {
                        
                        let _query = VSOProjectQuery()
                        let createdBy = VSOUser()
                        let lastModifiedBy = VSOUser()
                        if (x["hasChildren"] as? HasNumber)?.integerValue == 1{
                            if let ci = x["children"] as? [[String: Any]]{
                                let b = self.parseProjectQueries(items: ci, parentProject: _parentProject, parentQuery : _query)
                                _query.children.append(objectsIn: b)
                            }
                        }
                        //Set Author
                        if let a = x["createdBy"] as? [String:Any]{
                            createdBy.id = a["id"] as! String
                            createdBy.displayName = a["name"] as! String
                        }
                        //Set Modified
                        if let m = x["lastModifiedBy"] as? [String:Any]{
                            lastModifiedBy.id = m["id"] as! String
                            lastModifiedBy.displayName = m["name"] as! String
                        }
                        if let ls = x["_links"] as? [String:Any]{
                            _query._links.append(objectsIn: self.getLinks(links:ls))
                        }
                        _query.id = x["id"] as! String
                        _query.name = x["name"] as! String
                        _query.path = x["path"] as! String
                        _query.createdBy = createdBy
                        
                        _query.createdDate = DateFormatter().date(from: (x["createdDate"] as! String)) as NSDate?
                        _query.lastModifiedBy = lastModifiedBy
                        _query.lastModifiedDate = DateFormatter().date(from: (x["lastModifiedDate"]  as! String)) as NSDate?
                       
                        _query.isPublic.value = (x["isPublic"] as? HasNumber)?.integerValue
                        _query.isFolder.value = (x["isFolder"] as? HasNumber)?.integerValue
                        _query.hasChildren.value = (x["hasChildren"] as? HasNumber)?.integerValue
                        
                        _query.url = x["url"] as! String
                        _query.parentProject = _parentProject
                        
                        //QL1(_query)
                        try!  self.realm?.write {
                            self.realm?.add(_query,update: true)
                        }
                    }
                }
            }
            GradientLoadingBar.sharedInstance().hide()
            if(hasTasks==true && hasQueries == true){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "WorkItemQueriesViewController") as! WorkItemQueriesViewController
                vc.currentProject = _parentProject?.name
                vc.currentOrganisation = _parentProject?.owner?.accountName
                
                self.show(vc, sender: self)
            }
            else{
                VSORequest.getAllTasks(accountName: (self.organisationProjects?[row].owner?.accountName)!, project: (self.organisationProjects?[row].name)!) { (json, error) in
                    QL1(json)
                    QL4(error)
                }
                
                self.showAlert(message: "No Queries or Tasks to show")
            }
        })

    }
}
