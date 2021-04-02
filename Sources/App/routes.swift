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
    
    
    app.get("screen") {req -> EventLoopFuture<View> in
        return req.view.render("screening")
    }
    
    app.get("screen?q1=no1&q2=no2&q3=no3&q4=no4") { req -> EventLoopFuture<View> in
        return req.view.render("login")   
    }
    
    
    
    app.get("login") { req -> EventLoopFuture<View> in
        return req.view.render("login")
    }
    
    let websiteController = TodoController()
    try app.register(collection: websiteController)
    
}
