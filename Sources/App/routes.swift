import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        return req.view.render("index", ["name": "Leaf"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("employees") {req -> EventLoopFuture<View> in
        let josh = Employee(firstName: "Josh", lastName: "Taraba")
        return req.view.render("employees", ["employees":[josh]])
    }

    app.post("employees") {req -> EventLoopFuture<Employee> in
        let employee = try req.content.decode(Employee.self)
        
        return employee.save(on: req.db).map{ employee }
    }

}
