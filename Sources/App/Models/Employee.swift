//
//  Employee.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-12.
//

import Fluent
import Vapor

final class Employee: Model, Content {
    static let schema = "employees"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "username")
    var username: String
    
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
        self.role = .employee
    }
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var username: String
        
        init(id: UUID?, firstName: String, lastName: String, username: String) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
        }
    }
}

extension Employee {
    func convertToPublic() -> Employee.Public {
        return Employee.Public(id: id, firstName: firstName, lastName: lastName, username: username)
    }
}

extension EventLoopFuture where Value: Employee {
    func convertToPublic() -> EventLoopFuture<Employee.Public> {
        return self.map { employee in
            return employee.convertToPublic()
        }
    }
}

extension Collection where Element: Employee {
    func convertToPublic() -> [Employee.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<Employee> {
    func convertToPublic() -> EventLoopFuture<[Employee.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \Employee.$username
    static let passwordHashKey = \Employee.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
