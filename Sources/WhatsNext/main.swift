import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import Foundation

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

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
