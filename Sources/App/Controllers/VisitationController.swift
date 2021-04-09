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
        let visitorRoutes = routes.grouped("visitor")
        visitorRoutes.get("register", use: getVisitationHandler)
        visitorRoutes.post("register",use: createVisitorPostHandler)
        
        visitorRoutes.get("screening", use: screenHandler)
        visitorRoutes.post("screening", use: screenPostHandler)
        
        visitorRoutes.get("visitor","screening","fail", use: failScreenHandler)
        visitorRoutes.post("visitor","screening","fail", use: failScreenPostHandler)

        visitorRoutes.get("visitation-times", use: getVisitationTimesHandler)
    }
    
    
    func screenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitorScreening")
    }
    
    func screenPostHandler(_ req: Request) throws -> Response {
        let data = try req.content.decode(VisitorScreeningFormData.self)
        //let loginRedirect = req.redirect(to: "login")
        
        if data.visitorAnswer {
            // if answer yes to something
            return req.redirect(to: "visitor/screening/fail")
        }
        
        return req.redirect(to: "register")
    }
    
    
    // MARK: - Failed Screening Handlers
    
    func failScreenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitorScreeningFail")
    }
    
    func failScreenPostHandler(_ req: Request) throws -> Response {
        let res = try req.content.decode(VisitorFailScreeningData.self)

        if res.understand {
            return req.redirect(to: "/")
        }
        
        return req.redirect(to: "/")
    }
    
    //MARK: - Create Visitor
    func getVisitationHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitation")
    }
    
    func createVisitorPostHandler(_ req: Request) throws -> EventLoopFuture<Response>{
        let data = try req.content.decode(CreateVisitorData.self)
        let user = data.username
        let visitor = Visitor(
            firstName: data.firstName,
            lastName: data.lastName)
        
        return visitor.save(on: req.db).transform(to: req.redirect(to: "/visitor/visitation-times"))
    }
    
    func getVisitationTimesHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitationTimes")
    }
    
}

// MARK: - Screening structure

struct VisitorScreeningFormData: Content {
    let visitorAnswer: Bool
}

// MARK: - Fail Screening structure

struct VisitorFailScreeningData: Content {
    let understand: Bool
}

//MARK: - Visitor Structs

struct CreateVisitorData: Content {
    let firstName : String
    let lastName : String
    let username : User
}
