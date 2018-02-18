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
PostgresConnector.username = "todolist"
PostgresConnector.password = "todolistpassword"
PostgresConnector.database = "todolist_database"
PostgresConnector.port = 5432

let setupObject = ListItem()
try? setupObject.setup()

let itemController = TodoListAPIRouter()
let todoListRouter = TodoListRouter()
routes.add(itemController.routes)
routes.add(todoListRouter.routes)

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

