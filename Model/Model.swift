//
//  Model.swift
//  WhatsNext
//
//  Created by Alan O'Connor on 03/02/2018.
//

import Foundation

protocol Model {
    static func all() throws -> [ToDoItem]
    
    func asJSONDictionary() -> JSONDictionary
    
}
