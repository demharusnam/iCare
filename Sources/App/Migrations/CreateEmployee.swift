//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Foundation
import Fluent

struct CreateEmployee: Migration{
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("employees")
            .id()
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("employees").delete()
    }
}
