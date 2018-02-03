//
//  ToDoController.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 30/01/2018.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM

class ToDoController {
    var routes: [Route] {
        return [
            Route(method: .post, uri: "/new", handler: new),
            Route(method: .get, uri: "/all", handler: all),
            Route(method: .get, uri: "/first", handler: first),
            Route(method: .get, uri: "/priority", handler: byPriority),
            Route(method: .get, uri: "/everythingButTop", handler: everythingButTop),
            Route(method: .post, uri: "/update", handler: update),
            Route(method: .get, uri: "delete", handler: delete)
        ]
    }
    
    func new(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ToDoItemAPI.new(withRequest: request)
            response.setBody(string: json).JSONCompletedHeader()
        } catch  {
            response.completedInternalServerError(error: error)
        }
    }
    
    func all(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ToDoItemAPI.all()
            response.setBody(string: json).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }

    func first(request: HTTPRequest, response: HTTPResponse) {
        do {
            if let json = try ToDoItemAPI.first() {
                response.setBody(string: json).JSONCompletedHeader()
            } else {
                response.setBody(string: "").JSONCompletedHeader()
            }
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    func byPriority(request:HTTPRequest, response:HTTPResponse) {
        do {
            guard let priority =  request.param(name: "priority") else {
                response.completed(status: .badRequest)
                return
            }
            let itemsAsDictionaries = try ToDoItemAPI.itemsByPriority(priority: priority)
            try response.setBody(json: itemsAsDictionaries).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    func everythingButTop(request:HTTPRequest, response:HTTPResponse) {
        do {
            let toDoItems = try ToDoItemAPI.allItemsExceptHigh()
            try response.setBody(json: toDoItems).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    func update(request:HTTPRequest, response:HTTPResponse) {
        do {
            let item = try ToDoItemAPI.updateItem(withRequest: request)
            response.setBody(string: item).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    func delete(request: HTTPRequest, response: HTTPResponse) {
        do {
            let allItems = try ToDoItemAPI.deleteItem(withRequest: request)
            response.setBody(string: allItems).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
}
