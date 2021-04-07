import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        return req.view.render("login")
    }
    
    app.get("register") { req -> EventLoopFuture<View> in
        return req.view.render("register")
    }
    
    app.get("screening"){ req -> EventLoopFuture<View> in
        return req.view.render("screening")
    }
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let screeningController = ScreeningController()
    try app.register(collection: screeningController)
}
