//
//  ToDoItemAPI.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 30/01/2018.
//

import Foundation
import PerfectHTTP

class ToDoItemAPI {
    
    static func toDoItemToDictionary(toDoItems: [ToDoItem]) -> [[String: Any]] {
        var toDoItemJson: [[String:Any]] = []
        for row in toDoItems {
            toDoItemJson.append(row.asDisctionary())
        }
        return toDoItemJson
    }
    
    static func allAsDictionary() throws -> [[String: Any]] {
        let toDoItems = try ToDoItem.all()
        return toDoItemToDictionary(toDoItems: toDoItems)
    }
    
    static func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    static func new(withRequest request: HTTPRequest) throws -> String {
        guard let description = request.param(name: "description"), let priority = request.param(name: "priority") else {
            return "missing parameters"
        }
        return try ToDoItem.newItem(description: description, priority: priority).jsonEncodedString()
    }
    
    static func first() throws -> String? {
        return try ToDoItem.firstItem()?.asDisctionary().jsonEncodedString()
    }
    
    static func itemsByPriority(priority: String) throws -> [[String : Any]] {
        let priorityItems = try ToDoItem.itemsByPriority(priority: priority)
        
        let itemsAsDictionaries = priorityItems.map{ (item) in
            item.asDisctionary()
        }
        return itemsAsDictionaries
    }
    
    static func test() throws -> String {
        let toDoItem = ToDoItem()
        toDoItem.description = "Finish the DB part of this tutorial"
        try toDoItem.save() { id in
            toDoItem.id = id as! Int
        }
        return try all()
    }
    
    static func allItems(whereClause: String, params: [String], orderBy: [String]) throws -> [ToDoItem] {
        let getObj = ToDoItem()
        try getObj.select(whereclause: whereClause, params: params, orderby: orderBy)
        
        var toDoItems: [ToDoItem] = []
        for row in getObj.rows() {
            toDoItems.append(row)
        }
        return toDoItems
    }
    
    static func allItemsExceptHigh() throws -> [[String : Any]] {
        return try ToDoItemAPI.allItems(whereClause: "priority != $1", params: ["high"], orderBy: ["id"]).map({ (item) in
            item.asDisctionary()
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
        
        return try toDoItem.asDisctionary().jsonEncodedString()
    }
    
    static func deleteItem(withRequest request: HTTPRequest) throws -> String {
        guard let id = request.param(name: "id") else {
            return "missing ID - nothing to delete"
        }
        let allItems = try ToDoItem.deleteItem(byId: id)
        return try allItems.map{ (item) in
            item.asDisctionary()
        }.jsonEncodedString()
    }
}
