import Vapor
import Leaf
import Fluent

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.post(use: indexPostHandler)
    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        // 1. Query database for  relevent data
        // 2. Inject data into view as context
        // 3. Return the view
        return req.view.render("screening")
    }
    
    func indexPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(ScreeningFormData.self)
        let response: [EventLoopFuture<Void>] = []
        let redirect = req.redirect(to: "login")
        
        
        if data.answer {
            // if answer yes do something
            print("Yes")
        } else {
            // if answer no do something else
            print("No")
        }
        
        return response.flatten(on: req.eventLoop).transform(to: redirect)
    }
}

struct ScreeningFormData: Content {
    let answer: Bool
    let text: String
}
