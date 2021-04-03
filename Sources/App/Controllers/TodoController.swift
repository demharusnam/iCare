import Vapor
import Leaf
import Fluent

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("index")
    }
}
