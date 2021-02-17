//
//  Patient.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Vapor
import Fluent

final class Patient: Model {
    static let schema = "patients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "patientID")
    var patientID: Int
    
    @Field(key: "password")
    var password: String
    
    @Enum(key: "role")
    var role: Role
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, patientID: Int, password: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.patientID = patientID
        self.password = password
        self.role = .patient
    }
}

extension Patient: Content {}

