//
//  WorkItemQueriesViewController.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/08.
//  Copyright © 2017 NM. All rights reserved.
//

import UIKit
import RealmSwift
import QorumLogs
import ChameleonFramework
import GradientLoadingBar
class WorkItemQueriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    var currentOrganisation : String?
    var currentProject : String?
    let cellIdentifier = "QueriesCellIdentifier"
    var projectQueries : Results<VSOProjectQuery>?
    let needsSync : Bool? = false
    var realm : Realm?
    
    var previouslySelectedHeaderIndex: Int?
    var selectedHeaderIndex: Int?
    var selectedItemIndex: Int?
    
    var cells: SwiftyAccordionCells!

    override func viewDidLoad() {
        super.viewDidLoad()
        cells = SwiftyAccordionCells()
        setup()
        self.table.estimatedRowHeight = 45
        self.table.rowHeight = UITableViewAutomaticDimension
        self.table.allowsMultipleSelection = true
        self.automaticallyAdjustsScrollViewInsets = false        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.hidesNavigationBarHairline = true
        lblTitle.tintColor = UIColor.flatBlackDark
        
        //self.title = currentProject
    
        if needsSync == true {
            GradientLoadingBar.sharedInstance().show()
            VSORequest.getTeamProjectQueries(accountName: currentOrganisation!, project: currentProject!, completionHandler: {json , error in
                if(error != nil && json != nil){
                    print("We found some data yo")
                    print(json!)
                }
                else{
                    print("Error: \(String(describing: error as? String))")
                }
                GradientLoadingBar.sharedInstance().hide()
            })
        }
    }
    func setup() {
        realm = try! Realm()
        if let queries = realm?.objects(VSOProjectQuery.self).filter(NSPredicate(format: "parentProject.name == %@", currentProject!)){
            for query in queries{
                if query.children.count >= 1{
                    cells.append(SwiftyAccordionCells.HeaderItem(value: query.name, itemId: query.id, path: query.path))
                    for child in query.children{
                        cells.append(SwiftyAccordionCells.Item(value: child.name, itemId: child.id, path: child.path))
                    }
                }
            }
        }
        self.table.reloadData()
        if(cells.items.count == 0){
            self.showAlert(message: "No work item queries")
            VSORequest.getAllTasks(accountName: currentOrganisation!, project: currentProject!) { (json, error) in
                QL1(json)
                QL4(error)
            }
        }
        QL1(cells.items.count)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        let value = item.value
        let isChecked = item.isChecked as Bool
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell.textLabel?.text = value
            cell.detailTextLabel?.text = item.path
            if item as? SwiftyAccordionCells.HeaderItem != nil {
                cell.textLabel?.textColor = UIColor.flatBlackDark
                cell.detailTextLabel?.textColor = UIColor.flatGray
                
                //cell.backgroundColor = UIColor.lightGray.flatten()
                cell.accessoryType = .none
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.textColor = UIColor.flatBlackDark
                cell.detailTextLabel?.textColor = UIColor.flatGray
                cell.indentationWidth = 10
                if isChecked {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        
        if item is SwiftyAccordionCells.HeaderItem {
            return 60
        } else if (item.isHidden) {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        
        if item is SwiftyAccordionCells.HeaderItem {
            if self.selectedHeaderIndex == nil {
                self.selectedHeaderIndex = (indexPath as NSIndexPath).row
            } else {
                self.previouslySelectedHeaderIndex = self.selectedHeaderIndex
                self.selectedHeaderIndex = (indexPath as NSIndexPath).row
            }
            
            if let previouslySelectedHeaderIndex = self.previouslySelectedHeaderIndex {
                self.cells.collapse(previouslySelectedHeaderIndex)
            }
            
            if self.previouslySelectedHeaderIndex != self.selectedHeaderIndex {
                self.cells.expand(self.selectedHeaderIndex!)
            } else {
                self.selectedHeaderIndex = nil
                self.previouslySelectedHeaderIndex = nil
            }
            
            self.table.beginUpdates()
            self.table.endUpdates()
            
        } else {
            if (indexPath as NSIndexPath).row != self.selectedItemIndex {
                let cell = self.table.cellForRow(at: indexPath)
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                if let selectedItemIndex = self.selectedItemIndex {
                    let previousCell = self.table.cellForRow(at: IndexPath(row: selectedItemIndex, section: 0))
                    previousCell?.accessoryType = UITableViewCellAccessoryType.none
                    cells.items[selectedItemIndex].isChecked = false
                }
                
                self.selectedItemIndex = (indexPath as NSIndexPath).row
                cells.items[self.selectedItemIndex!].isChecked = true
                print(cells.items[self.selectedItemIndex!].id as Any)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProjectTasksViewController") as! ProjectTasksViewController
                vc.queryID = cells.items[self.selectedItemIndex!].id!
                vc.currentProject = currentProject!
                vc.currentOrganisation = currentOrganisation!
                vc.needsSync = true
                self.show(vc, sender: self)
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
