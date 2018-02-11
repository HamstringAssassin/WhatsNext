//
//  Controller.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 09/02/2018.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

protocol RouteController {
    var routes: [Route] { get }
}

final class Controller: RouteController {
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/todolist", handler: indexView),
            Route(method: .post, uri: "/todolist", handler: addItem),
            Route(method: .post, uri: "/todolist/{id}/delete", handler: delete),
            Route(method: .post, uri: "/todolist/{id}/complete", handler: complete)
        ]
    }
    
    fileprivate func delete(request: HTTPRequest, response: HTTPResponse) {
        do {
            let _ = try ListItemAPI.deleteItem(withRequest: request)
            response.setHeader(.location, value: "/todolist").completed(status: .movedPermanently)
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    fileprivate func complete(request: HTTPRequest, response: HTTPResponse) {
        do {
            let _ = try ListItemAPI.completeItem(withRequest: request)
            response.setHeader(.location, value: "/todolist").completed(status: .movedPermanently)
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    fileprivate func addItem(request: HTTPRequest, response: HTTPResponse) {
        do {
            let _ = try ListItemAPI.new(withRequest: request)
            response.setHeader(.location, value: "/todolist").completed(status: .movedPermanently)
        } catch {
            response.completedInternalServerError(error: error)
        }
    }
    
    fileprivate func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            var values = MustacheEvaluationContext.MapType()
            values["listItems"] = try ListItemAPI.allWithRequest(request: request)
            
            mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/index.html")
        } catch  {
            response.completedInternalServerError(error: error)
        }
    }
}
