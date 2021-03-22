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
            .case("nurse")
            .case("doctor")
            .case("patient")
            .case("employee")
            .case("visitor")
            .create()
            .flatMap { role in
                database.schema(Patient.schema)
                    .id()
                    .field("firstName", .string, .required)
                    .field("lastName", .string, .required)
                    .field("patientID", .int, .required)
                    .field("password", .string, .required)
                    .field("role", role, .required)
                    .unique(on: "patientID")
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Patient.schema).delete()
    }
}
