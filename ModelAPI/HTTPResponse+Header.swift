//
//  HTTPResponse+Header.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 30/01/2018.
//

import Foundation
import PerfectHTTP


extension HTTPResponse {
    func JSONCompletedHeader() {
        return self.setHeader(.contentType, value: "application/json").completed()
    }
    
    func completedInternalServerError(error: Error) {
        return self.setBody(string: "Error handling request \(error)").completed(status: .internalServerError)
    }
}
