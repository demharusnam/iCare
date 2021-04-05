import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
    
    app.get("employees") {req -> EventLoopFuture<View> in
        return req.view.render("employees")
    }

    app.post("employees") {req -> EventLoopFuture<Employee> in
        let employee = try req.content.decode(Employee.self)
        return employee.save(on: req.db).map{ employee }
    }
    
    
//    app.get("screen") {req -> EventLoopFuture<View> in
//        return req.view.render("screening")
//    }
//
// 
    
    
    app.get("login") { req -> EventLoopFuture<View> in
        return req.view.render("login")
    }
    
    app.get("account") { req -> EventLoopFuture<View> in
        return req.view.render("account")
    }
    
    app.get("screenfail") { req -> EventLoopFuture<View> in
        return req.view.render("screenfail")
    }
    
    
    
    let websiteController = TodoController()
    try app.register(collection: websiteController)
    
}
