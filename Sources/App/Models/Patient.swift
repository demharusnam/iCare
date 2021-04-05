//
//  Patient.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Fluent
import Vapor

final class Patient: Model, Content {
    static let schema = "patients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "patientID")
    var patientID: Int

    @Field(key: "firstName")
    var firstName: String
    
    @Field(key: "lastName")
    var lastName: String
    
    init() {}
    
    init(id: UUID? = nil, patientID: Int, firstName: String, lastName: String) {
        self.id = id
        self.patientID = patientID
        self.firstName = firstName
        self.lastName = lastName
    }
}

