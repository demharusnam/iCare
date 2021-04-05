//
//  Patient.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Vapor
import Fluent

final class Patient: Model, Content {
    static let schema = "patients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "username")
    var patientID: Int
    
    @Field(key: "password")
    var password: String
    
    @Enum(key: "role")
    var role: Role
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, username: String, password: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.role = .patient
    }
}

