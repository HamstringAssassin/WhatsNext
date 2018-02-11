//
//  ListItem.swift
//  WhatsNextPackageDescription
//
//  Created by Alan O'Connor on 20/01/2018.
//

import Foundation
import StORM
import PostgresStORM

class ListItem: PostgresStORM {
    
    enum priorityColor: String {
        case red = "#FF0000"
        case orange = "#FFA500"
        case green = "#008000"
    }
    
    enum itemPriority: String {
        case high
        case medium
        case low
        
        var color: String {
            switch self {
            case .high:
                return priorityColor.red.rawValue
            case .medium:
                return priorityColor.orange.rawValue
            case .low:
                return priorityColor.green.rawValue
            }
        }
        
        var priorityValue: Int {
            switch self {
            case .high:
                return 0
            case .medium:
                return 1
            case .low:
                return 2
            }
        }
    }

    fileprivate var id: Int = 0
    fileprivate var description: String = ""
    fileprivate var priority: String = "medium"
    fileprivate (set) var visible: Bool = true
    
    var itemColor: String {
        return itemPriority(rawValue: self.priority)?.color ?? "#000000"
    }
    
    var priorityValue: Int {
        return itemPriority(rawValue: self.priority)?.priorityValue ?? 0
    }
    
    override func table() -> String {
        return "toDoList"
    }
    
    // to convert a row of data into an object
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        description = this.data["description"] as? String ?? ""
        priority = this.data["priority"] as? String ?? ""
        visible = this.data["visible"] as? Bool ??  true
    }
    
    fileprivate func rows() -> [ListItem] {
        var rows = [ListItem]()
        for i in 0..<self.results.rows.count {
            let row = ListItem()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asJSONDictionary() -> JSONDictionary {
        return ["id":self.id, "description":self.description, "priority": self.priority, "visible": self.visible, "color": self.itemColor   ]
    }
    
    func updateItemVisibilty() throws {
        self.visible = !self.visible
        try self.save()
    }
    
    static func itemsToJSONArray(items: [ListItem]) -> JSONArray {
        return items.map{ (item) in
            item.asJSONDictionary()
        }
    }
    
    static func allAsJSONArray() throws -> JSONArray {
        let listItems = try ListItem.allItems()
        return itemsToJSONArray(items: listItems)
    }
    
    static func all() throws -> String {
        return try allAsJSONArray().jsonEncodedString()
    }
    
    static func allItems() throws -> [ListItem] {
        let getObject = ListItem()
        try getObject.findAll()
        return getObject.rows()
    }
    
    static func newItem(description: String, priority: String) throws -> ListItem {
        let todoItem = ListItem()
        todoItem.description = description
        todoItem.priority = priority
        todoItem.visible = true
        try todoItem.save() { id in
            todoItem.id = id as! Int
        }
        return todoItem
    }
    
    static func item(byId id: String) throws -> ListItem? {
        let getObject = ListItem()
        var searchData = JSONDictionary()
        searchData["id"] = id
        
        try getObject.find(searchData)
        return getObject.rows().first
    }
    
    static func selectAllItems(whereClause: String?, params: [String], orderBy: [String] = ["id"]) throws -> [ListItem] {
        let getObj = ListItem()
        if let whereClause = whereClause {
            try getObj.select(whereclause: whereClause, params: params, orderby: orderBy)
        } else {
            try getObj.findAll()
        }
        
        var toDoItems: [ListItem] = []
        for row in getObj.rows() {
            toDoItems.append(row)
        }
        return toDoItems
    }
    
    static func updateItem(byId id: String, withDescription description: String?, andPriority priority: String?, andVisibility visible: String?) throws -> ListItem? {
        guard let item = try ListItem.item(byId: id) else { return nil }
        item.description = description ?? item.description
        item.priority = priority ?? item.priority
        if let visible = visible {
            item.visible = NSString(string: visible).boolValue
        }
        try item.save()
        return item
    }
    
    static func deleteItem(byId id: String) throws -> [ListItem] {
        let item = try ListItem.item(byId: id)
        try item?.delete()
        return try ListItem.allItems()
    }
    
    
}
