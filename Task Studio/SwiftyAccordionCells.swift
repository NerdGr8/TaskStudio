//
//  SwiftyAccordionCells.swift
//  Task Studio
//
//  Created by Nerudo Mregi on 2017/02/10.
//  Copyright © 2017 NM. All rights reserved.
//

import Foundation
class SwiftyAccordionCells {
    fileprivate (set) var items = [Item]()
    
    class Item {
        var isHidden: Bool
        var value: String
        var id : String? //Stores the ID of the Item
        var childCount : Int?
        var path : String?
        var isChecked: Bool
        
        init(_ hidden: Bool = true, value: String, checked: Bool = false, itemId : String, path : String) {
            self.isHidden = hidden
            self.value = value
            self.isChecked = checked
            self.id = itemId
            self.path = path
        }
    }
    
    class HeaderItem: Item {
        init (value: String, itemId : String, path : String) {
            super.init(false, value: value, checked: false, itemId: itemId, path : path)
        }
    }
    
    func append(_ item: Item) {
        self.items.append(item)
    }
    
    func removeAll() {
        self.items.removeAll()
    }
    
    func expand(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: false)
    }
    
    func collapse(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: true)
    }
    
    private func toogleVisible(_ headerIndex: Int, isHidden: Bool) {
        var headerIndex = headerIndex
        headerIndex += 1
        
        while headerIndex < self.items.count && !(self.items[headerIndex] is HeaderItem) {
            self.items[headerIndex].isHidden = isHidden
            
            headerIndex += 1
        }
    }
}
