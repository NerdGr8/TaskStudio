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
class VSOAccount : Object{
    dynamic var accountId = "";
    dynamic var accountUri = "";
    dynamic var accountName = "";
    dynamic var organizationName = "";
    dynamic var accountType = "";
    dynamic var accountOwner = "";
    dynamic var createdBy = "";
    dynamic var createdDate = "";
    dynamic var accountStatus = "";
    dynamic var owner: VsoUserAccount?
    override static func indexedProperties() -> [String] {
        return ["accountId"]
    }
    override static func primaryKey() -> String? {
        return "accountId"
    }
}
class VSOProject : Object{
    dynamic var id = "";
    dynamic var name = "";
    dynamic var projectDescription = "";
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
