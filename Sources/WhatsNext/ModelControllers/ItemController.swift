//
//  ItemController.swift
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

class ItemController {
    var routes: [Route] {
        return [
            Route(method: .post, uri: "/new", handler: new),
            Route(method: .get, uri: "/all", handler: allWithParams),
//            Route(method: .get, uri: "/first", handler: first),
//            Route(method: .get, uri: "/priority", handler: byPriority),
//            Route(method: .get, uri: "/everythingButTop", handler: everythingButTop),
            Route(method: .post, uri: "/update", handler: update),
            Route(method: .get, uri: "/delete", handler: delete),
//            Route(method: .get, uri: "/allVisible", handler: byVisibilty)
        ]
    }
    
    func new(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItemAPI.new(withRequest: request)
            response.setBody(string: json).JSONCompletedHeader()
        } catch  {
            response.completedInternalServerError(error: error)
        }
    }
    
    func allWithParams(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItemAPI.allWithRequest(request: request)
            response.setBody(string: json).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }

    
    func all(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItem.all()
            response.setBody(string: json).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }

//    func first(request: HTTPRequest, response: HTTPResponse) {
//        do {
//            if let json = try ListItemAPI.first() {
//                response.setBody(string: json).JSONCompletedHeader()
//            } else {
//                response.setBody(string: "").JSONCompletedHeader()
//            }
//        } catch {
//            response.completedInternalServerError(error: error)
//        }
//    }
    
//    func byVisibilty(request:HTTPRequest, response:HTTPResponse) {
//        do {
//            guard let visible =  request.param(name: "visible") else {
//                response.completed(status: .badRequest)
//                return
//            }
//            let itemsAsDictionaries = try ListItemAPI.itemsByVisiblity(visibility: visible)
//            try response.setBody(json: itemsAsDictionaries).JSONCompletedHeader()
//        } catch {
//            response.completedInternalServerError(error: error)
//        }
//    }
    
    
//    func byPriority(request:HTTPRequest, response:HTTPResponse) {
//        do {
//            guard let priority =  request.param(name: "priority") else {
//                response.completed(status: .badRequest)
//                return
//            }
//            let itemsAsDictionaries = try ListItemAPI.itemsByPriority(priority: priority)
//            try response.setBody(json: itemsAsDictionaries).JSONCompletedHeader()
//        } catch {
//            response.completedInternalServerError(error: error)
//        }
//    }
//
//    func everythingButTop(request:HTTPRequest, response:HTTPResponse) {
//        do {
//            let toDoItems = try ListItemAPI.allItemsExceptHigh()
//            try response.setBody(json: toDoItems).JSONCompletedHeader()
//        } catch {
//            response.completedInternalServerError(error: error)
//        }
//    }
    
    func update(request:HTTPRequest, response:HTTPResponse) {
        do {
            let item = try ListItemAPI.updateItem(withRequest: request)
            response.setBody(string: item).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    func delete(request: HTTPRequest, response: HTTPResponse) {
        do {
            let allItems = try ListItemAPI.deleteItem(withRequest: request)
            response.setBody(string: allItems).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
}
