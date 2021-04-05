//
//  CreatePatient.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Fluent

struct CreatePatient: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum(Role.schema)
            .read()
            .flatMap { role in
                database.schema(Patient.schema)
                    .id()
                    .field("firstName", .string, .required)
                    .field("lastName", .string, .required)
                    .field("username", .string, .required)
                    .field("password", .string, .required)
                    .field("role", role, .required)
                    .unique(on: "username")
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Patient.schema).delete()
    }
}
