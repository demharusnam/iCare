//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-09.
//

import Fluent
import Vapor

struct VisitationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("visitor", use: getVisitation)
    }
    
    func getVisitation(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitation")
    }
}
