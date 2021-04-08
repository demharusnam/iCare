//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-07.
//

import Vapor
import Fluent

final class Appointment: Model {
    static let schema = "appointments"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "date")
    var date: Date
    
    @Parent(key: "userID")
    var user: User
    
    init() {}
    
    init(id:UUID? = nil, name: String, description: String, date: Date, userID: User.IDValue){
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.$user.id = userID
    }
}

extension Appointment: Content {}
