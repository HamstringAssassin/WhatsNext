import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation
import PerfectMustache

import PostgresStORM
import StORM

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

PostgresConnector.host = "localhost"
PostgresConnector.username = "perfect"
PostgresConnector.password = "perfect"
PostgresConnector.database = "perfect_testing"
PostgresConnector.port = 5432

    let setupObject = ToDoItem()
    try? setupObject.setup()

func test(request: HTTPRequest, response: HTTPResponse) {
    do {
        let toDoItem = ToDoItem()
        toDoItem.description = "Finish the DB part of this tutorial"
        try toDoItem.save() { id in
            toDoItem.id = id as! Int
        }
        
        //Get all toDoItems as a Dictionary
        let getObject = ToDoItem()
        try getObject.findAll()
        var toDoItems: [[String: Any]] = []
        for row in getObject.rows() {
            toDoItems.append(row.asDisctionary())
        }
        
        try response.setBody(json: toDoItems).setHeader(.contentType, value: "application/json").completed()
        
    } catch  {
        response.setBody(string: "Error handling request \(error)").completed(status: .internalServerError)
    }
}

routes.add(method: .get, uri: "/test", handler: test)


struct MustacheHelper: MustachePageHandler {
    var values: MustacheEvaluationContext.MapType
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        contxt.extendValues(with: values)
        
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.appendBody(string: "\(error)")
            .completed(status: .internalServerError)
        }
    }
}

func helloMustache(request: HTTPRequest, response: HTTPResponse) {
    var values = MustacheEvaluationContext.MapType()
    values["name"] = "HammyAssassin"
    mustacheRequest(request: request, response: response, handler:  MustacheHelper(values: values), templatePath: request.documentRoot + "/" + "hello.html")
}

routes.add(method: .get, uri: "/helloMustache", handler: helloMustache)

func readTXTFile() -> String {
    var readText = ""
    do {
        try readText = String(contentsOfFile: "webroot/hello.txt")
    } catch let error as NSError {
        readText = "Something went wrong. See log for details."
        print("Something went wrong with reading the file. \(error.localizedDescription)")
    }
    return readText
}

routes.add(method: .get, uri: "/") { (request, response) in
    let string = readTXTFile()
    response.setBody(string: string)
    .completed()
}

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
