//
//  CreateVisitor.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-17.
//

import Fluent

struct CreateVisitor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum(Role.schema)
            .case("nurse")
            .case("doctor")
            .case("patient")
            .case("employee")
            .case("visitor")
            .create()
            .flatMap { role in
                database.schema(Visitor.schema)
                    .id()
                    .field("firstName", .string, .required)
                    .field("lastName", .string, .required)
                    .field("role", role, .required)
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visitor.schema).delete()
    }
}
