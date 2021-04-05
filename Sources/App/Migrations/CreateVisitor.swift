//
//  CreateVisitor.swift
//  
//
<<<<<<< HEAD
//  Created by Mansur Ahmed on 2021-04-05.
=======
//  Created by Mansur Ahmed on 2021-02-17.
>>>>>>> 29967919241733e3b4fda8172c1725623d8f8caa
//

import Fluent

struct CreateVisitor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
<<<<<<< HEAD
        database.schema(Visitor.schema)
            .id()
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visitor.schema)
            .delete()
=======
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
>>>>>>> 29967919241733e3b4fda8172c1725623d8f8caa
    }
}
