//
//  VsoModels.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/05.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
import RealmSwift

class UserAccount : Object{
    dynamic var password = ""
    dynamic var emailAddress = ""
    let id = RealmOptional<Int>()
    let vsoAccount = List<VsoUserAccount>()
}
class VsoUserAccount : Object{
    dynamic var displayName = "";
    dynamic var emailAddress = "";
    dynamic var id = "";
    dynamic var publicAlias = "";
    dynamic var owner: UserAccount?
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
/*
    Orgnisation Account
 */
class VSOAccount : Object{
    dynamic var accountId = ""
    dynamic var accountUri = ""
    dynamic var accountName = ""
    dynamic var organizationName : String? = nil
    dynamic var accountType : String? = nil
    dynamic var createdBy : String? = nil
    dynamic var createdDate : String? = nil
    dynamic var accountStatus : String? = nil
    dynamic var owner: VsoUserAccount?
    override static func indexedProperties() -> [String] {
        return ["accountId"]
    }
    override static func primaryKey() -> String? {
        return "accountId"
    }
}
//Projects belong to an Account/Organisation Account
class VSOProject : Object{
    dynamic var id = "";
    dynamic var name = "";
    dynamic var projectDescription : String?
    dynamic var url = "";
    dynamic var state = "";
    dynamic var owner: VSOAccount?
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
//Project/Author/CreatedBy 
class VSOUser : Object{
    dynamic var id = ""
    dynamic var displayName = ""
    dynamic var imageUrl : String?
    dynamic var url : String?
    override static func indexedProperties() -> [String] {
        return ["displayName"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
class VSOLink : Object{
   dynamic var key = ""
  dynamic  var href = ""
    override static func primaryKey() -> String? {
        return "key"
    }
}
//PROJECT Queries - Used to get work items
class VSOProjectQuery : Object{
    dynamic var id = ""
    dynamic var name = ""
    dynamic var path = ""
    dynamic var createdBy : VSOUser?
    dynamic var createdDate : NSDate? = nil
    dynamic var lastModifiedBy : VSOUser?
    dynamic var lastModifiedDate : NSDate? = nil
     let isFolder = RealmOptional<Int>()
     let hasChildren = RealmOptional<Int>()
            var children = List<VSOProjectQuery>()
    let isPublic = RealmOptional<Int>()
    let _links = List<VSOLink>()
    dynamic var url = ""
    dynamic var parentProject : VSOProject?
    dynamic var parentQuery : VSOProjectQuery?
    let tasks = List<VSOTask>() //Added since its used to quickly get the project's tasks
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
//WORK ITEMS
class VSOTask : Object{
    dynamic var id = 0
    dynamic var url = ""
    dynamic var parentProject : VSOProject?
    let columns = List<VSOColumn>()
    let ownerQuery = LinkingObjects(fromType: VSOProjectQuery.self, property: "tasks")
    dynamic var rev = 0
    dynamic var title : String?
    dynamic var state : String?
    dynamic var taskDescription : String?
    dynamic var teamProject : String?
    dynamic var assignedTo : String?
    dynamic var createdBy : String?
    dynamic var changedBy : String?
    dynamic var priority : String?
    dynamic var iterationPath : String?
    dynamic var workItemType : String?
    //DATA
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
class VSORelation : Object {
  
}
class VSOColumn : Object{
    dynamic var referenceName = ""
    dynamic var displayName = ""
    dynamic var url = ""
    override static func indexedProperties() -> [String] {
        return ["displayName"]
    }
    override static func primaryKey() -> String? {
        return "referenceName"
    }
}
class VSOChatTeam : Object{
    dynamic var name = ""
    dynamic var createdBy : VSOUser?
    dynamic var createdDate: TimeInterval = 0
    dynamic var roomDescription = ""
    dynamic var hasAdminPermissions = 0
    dynamic var hasReadWritePermissions = 0
    dynamic var id = 0
    dynamic var lastActivity: String = ""
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
class VSOChatMessage : Object{
    dynamic var postedBy : VSOUser?
    dynamic var postedTime: String = ""
    dynamic var messageType = ""
    dynamic var postedRoomId = 0
    dynamic var id = 0
    dynamic var content: String = ""
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}
//Saves all current session configurations [ NOT USED ]
class CurrentSession : Object{
    dynamic var currentOrganizationName = ""
    dynamic var currentProject : VSOProject?
}
