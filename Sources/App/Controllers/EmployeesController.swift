//
//  EmployeesController.swift
//  
//
//  Created by Mansur Ahmed on 2021-04-05.
//

import Vapor
import Fluent

struct EmployeesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let employeesRoutes = routes.grouped("employee")
        
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        
        return acronym.save(on: req.db).map { acronym }
    }
}
