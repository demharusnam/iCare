import Vapor
import Leaf
import Fluent

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let screenRoutes = routes.grouped("screening")
        screenRoutes.get(use: screenHandler)
        screenRoutes.post(use: screenPostHandler)
        
        let failScreenRoutes = routes.grouped("screenfail")
        failScreenRoutes.get(use: failScreenHandler)
        failScreenRoutes.post(use: failScreenPostHandler)
    }
    
    /*The screening page
        ------------------------
    */
    
    func screenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("screening")
    }
    
    func screenPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(ScreeningFormData.self)
        let response: [EventLoopFuture<Void>] = []
        let loginRedirect = req.redirect(to: "login")
        let failedRedirect = req.redirect(to: "screenfail")
        let accountRedirect = req.redirect(to: "account")
        
        
        if data.answer {
            // if answer yes do something
            return response.flatten(on: req.eventLoop).transform(to: failedRedirect)
        } else {
            return response.flatten(on: req.eventLoop).transform(to: accountRedirect)
        }
    }
    
    
    /*If the user fails the screen
        ------------------------
    */
    
    func failScreenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("screenfail")
    }
    
    func failScreenPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let res = try req.content.decode(FailScreeningData.self)
        let response: [EventLoopFuture<Void>] = []
        let accountRedirect = req.redirect(to: "account")
        let loginRedirect = req.redirect(to: "login")

        if res.understand {
            print("understood")
            return response.flatten(on: req.eventLoop).transform(to: accountRedirect)
        } else {
        }
        return response.flatten(on: req.eventLoop).transform(to: loginRedirect)
    }
}

//Screening structure
struct ScreeningFormData: Content {
    let answer: Bool
}

//Fail Screening structure
struct FailScreeningData: Content {
    let understand: Bool
}
