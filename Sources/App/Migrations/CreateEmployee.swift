//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Fluent

struct CreateEmployee: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Employee.schema)
            .id()
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Employee.schema)
            .delete()
    }
}
