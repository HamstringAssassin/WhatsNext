//
//  ToDoItemAPI.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 30/01/2018.
//

import Foundation
import PerfectHTTP

class ToDoItemAPI {
    
    static func itemsToJSONArray(items: [ToDoItem]) -> JSONArray {
        return items.map{ (item) in
            item.asJSONDictionary()
        }
    }
    
    static func allAsJSONArray() throws -> JSONArray {
        let toDoItems = try ToDoItem.all()
        return itemsToJSONArray(items: toDoItems)
    }
    
    static func all() throws -> String {
        return try allAsJSONArray().jsonEncodedString()
    }
    
    static func new(withRequest request: HTTPRequest) throws -> String {
        guard let description = request.param(name: "description"), let priority = request.param(name: "priority") else {
            return "missing parameters"
        }
        return try ToDoItem.newItem(description: description, priority: priority).asJSONDictionary().jsonEncodedString()
    }
    
    static func first() throws -> String? {
        return try ToDoItem.firstItem()?.asJSONDictionary().jsonEncodedString()
    }
    
    static func itemsByPriority(priority: String) throws -> JSONArray {
        let priorityItems = try ToDoItem.itemsByPriority(priority: priority)
        
        return priorityItems.map{ (item) in
            item.asJSONDictionary()
        }
    }
    
    static func allItemsExceptHigh() throws -> JSONArray {
        return try ToDoItem.selectAllItems(whereClause: "priority != $1", params: ["high"], orderBy: ["id"]).map({ (item) in
            item.asJSONDictionary()
        })
    }
    
    static func updateItem(withRequest request: HTTPRequest) throws -> String {
        let description = request.param(name: "description")
        let priority = request.param(name: "priority")
        guard let id = request.param(name: "id") else {
            return "missing ID - nothing to update"
        }
        
        guard let toDoItem = try ToDoItem.updateItem(byId: id, withDescription: description, andPriority: priority) else {
            return "unable to update item"
        }
        
        return try toDoItem.asJSONDictionary().jsonEncodedString()
    }
    
    static func deleteItem(withRequest request: HTTPRequest) throws -> String {
        guard let id = request.param(name: "id") else {
            return "missing ID - nothing to delete"
        }
        let allItems = try ToDoItem.deleteItem(byId: id)
        return try allItems.map{ (item) in
            item.asJSONDictionary()
        }.jsonEncodedString()
    }
}
