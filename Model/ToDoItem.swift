//
//  ToDoItem.swift
//  WhatsNextPackageDescription
//
//  Created by Alan O'Connor on 20/01/2018.
//

import Foundation
import StORM
import PostgresStORM

class ToDoItem: PostgresStORM {
    
    var id: Int = 0
    var description: String = ""
    var priority: String = "medium"
    
    override func table() -> String {
        return "toDoList"
    }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        description = this.data["description"] as? String ?? ""
        priority = this.data["priority"] as? String ?? ""
    }
    
    func rows() -> [ToDoItem] {
        var rows = [ToDoItem]()
        for i in 0..<self.results.rows.count {
            let row = ToDoItem()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asJSONDictionary() -> JSONDictionary {
        return ["id":self.id, "description":self.description, "priority": self.priority]
    }
    
    static func all() throws -> [ToDoItem] {
        let getObject = ToDoItem()
        try getObject.findAll()
        return getObject.rows()
    }
    
    static func newItem(description: String, priority: String) throws -> ToDoItem {
        let todoItem = ToDoItem()
        todoItem.description = description
        todoItem.priority = priority
        try todoItem.save() { id in
            todoItem.id = id as! Int
        }
        return todoItem
    }
    
    static func item(byId id: String) throws -> ToDoItem? {
        let getObject = ToDoItem()
        var searchData = JSONDictionary()
        searchData["id"] = id
        
        try getObject.find(searchData)
        return getObject.rows().first
    }
    
    static func firstItem() throws -> ToDoItem? {
        let getObj = ToDoItem()
        let cursor = StORMCursor(limit: 1, offset: 0)
        try getObj.select(whereclause: "true", params: [], orderby: ["id"], cursor: cursor)
        return getObj.rows().first
    }
    
    static func itemsByPriority(priority: String) throws -> [ToDoItem] {
        let getObj = ToDoItem()
        var searchData = JSONDictionary()
        searchData["priority"] = priority
        
        try getObj.find(searchData)
        var toDoItems: [ToDoItem] = []
        for row in getObj.rows() {
            toDoItems.append(row)
        }
        return toDoItems
    }
    
    static func selectAllItems(whereClause: String, params: [String], orderBy: [String]) throws -> [ToDoItem] {
        let getObj = ToDoItem()
        try getObj.select(whereclause: whereClause, params: params, orderby: orderBy)
        
        var toDoItems: [ToDoItem] = []
        for row in getObj.rows() {
            toDoItems.append(row)
        }
        return toDoItems
    }
    
    static func updateItem(byId id: String, withDescription description: String?, andPriority priority: String?) throws -> ToDoItem? {
        guard let item = try ToDoItem.item(byId: id) else { return nil }
        item.description = description ?? item.description
        item.priority = priority ?? item.priority
        try item.save()
        return item
    }
    
    static func deleteItem(byId id: String) throws -> [ToDoItem] {
        let item = try ToDoItem.item(byId: id)
        try item?.delete()
        return try ToDoItem.all()
        
    }

}
