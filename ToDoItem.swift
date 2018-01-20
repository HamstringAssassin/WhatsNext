//
//  ToDoItem.swift
//  WhatsNextPackageDescription
//
//  Created by Alan O'Connor on 20/01/2018.
//

import Foundation
import StORM
import PostgresStORM

class ToDoItem: PostgresStORM {
    
    var id: Int = 0
    var description: String = ""
    
    
    override func table() -> String {
        return "toDoList"
    }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        description = this.data["description"] as? String ?? ""
    }
    
    func rows() -> [ToDoItem] {
        var rows = [ToDoItem]()
        for i in 0..<self.results.rows.count {
            let row = ToDoItem()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDisctionary() -> [String: Any] {
        return ["id":self.id, "description":self.description]
    }
}
