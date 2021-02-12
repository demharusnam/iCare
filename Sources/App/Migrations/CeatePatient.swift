//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Foundation
import Fluent


struct CreatePatient: Migration{
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patients")
            .id()
            .field("patientID", .int, .required)
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("patients").delete()
    }
}