//
//  ListItemAPI.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 30/01/2018.
//

import Foundation
import PerfectHTTP

class ListItemAPI {
    
    static func new(withRequest request: HTTPRequest) throws -> String {
        guard let description = request.param(name: "description"), let priority = request.param(name: "priority") else {
            return "missing parameters"
        }
        return try ListItem.newItem(description: description, priority: priority).asJSONDictionary().jsonEncodedString()
    }

    /*
     We are returning all items from the DB, and using swift methods to
     return only visible items. We also sort the items using swift to return in order of priority.
     */
    static func allWithRequest(request: HTTPRequest) throws ->  JSONArray {
        var paramValues = [String]()
        var paramKeys = [String]()
        var whereclause = ""
        
        for (paramKey, paramValue) in request.params() {
            paramValues.append(paramValue)
            paramKeys.append(paramKey)
            let index = paramValues.index(of: paramValue) ?? 0
            if index != 0 {
                whereclause.append(" and ")
            }
            whereclause.append("\(paramKey) = $\(String(describing: index + 1))")
        }
    
        let items = try ListItem.selectAllItems(whereClause: whereclause, params: paramValues, orderBy: ["id"])
        return items
            .filter({ (item) -> Bool in
                item.visible
            })
            .sorted(by: { (first, second) -> Bool in
                first.priorityValue < second.priorityValue
            })
            .map({ (item) in
            item.asJSONDictionary()
        })
    }

    static func updateItem(withRequest request: HTTPRequest) throws -> String {
        let description = request.param(name: "description")
        let priority = request.param(name: "priority")
        let visible = request.param(name: "visible")
        guard let id = request.param(name: "id") else {
            return "missing ID - nothing to update"
        }
        
        guard let toDoItem = try ListItem.updateItem(byId: id, withDescription: description, andPriority: priority, andVisibility: visible) else {
            return "unable to update item"
        }
        
        return try toDoItem.asJSONDictionary().jsonEncodedString()
    }
    
    static func completeItem(withRequest request: HTTPRequest) throws -> String? {
        guard let id = request.urlVariables["id"] else {
            return "missing ID - nothing to delete"
        }
        let item = try ListItem.item(byId: id)
        try item?.updateItemVisibilty()
        return try item?.asJSONDictionary().jsonEncodedString()
    }
    
    static func deleteItem(withRequest request: HTTPRequest) throws -> String {
        guard let id = request.urlVariables["id"] else {
            return "missing ID - nothing to delete"
        }
        let allItems = try ListItem.deleteItem(byId: id)
        return try allItems.map{ (item) in
            item.asJSONDictionary()
        }.jsonEncodedString()
    }
}
