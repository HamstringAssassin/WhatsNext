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
            Route(method: .post, uri: "/update", handler: update),
            Route(method: .get, uri: "/delete", handler: delete),
        ]
    }
    
    fileprivate func new(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItemAPI.new(withRequest: request)
            response.setBody(string: json).JSONCompletedHeader()
        } catch  {
            response.completedInternalServerError(error: error)
        }
    }
    
    fileprivate func allWithParams(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItemAPI.allWithRequest(request: request).jsonEncodedString()
            response.setBody(string: json).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }

    
    fileprivate func all(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try ListItem.all()
            response.setBody(string: json).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }

    fileprivate func update(request:HTTPRequest, response:HTTPResponse) {
        do {
            let item = try ListItemAPI.updateItem(withRequest: request)
            response.setBody(string: item).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    fileprivate func delete(request: HTTPRequest, response: HTTPResponse) {
        do {
            let allItems = try ListItemAPI.deleteItem(withRequest: request)
            response.setBody(string: allItems).JSONCompletedHeader()
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
}
