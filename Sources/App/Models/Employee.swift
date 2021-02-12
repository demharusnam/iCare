//
//  Employee.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-12.
//

import Fluent
import Vapor

final class Employee: Model, Employee {
    static let schema = "employees"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String

    @Field(key: "employeeID")
    var employeeID: Int
    
    @Field(key: "role")
    var role: Role
    
    init() {}

    init(id: UUID? = nil, firstName: String, lastName: String, employeeID: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.employeeID = employeeID
        self.role = .doctor
    }
}

extension Employee: Content {}
