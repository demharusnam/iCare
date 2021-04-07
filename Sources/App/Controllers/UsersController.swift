//
//  EmployeesController.swift
//  
//
//  Created by Mansur Ahmed on 2021-04-05.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authSessionsRoutes = routes.grouped(User.sessionAuthenticator())
        authSessionsRoutes.get(use: loginHandler)
        
        let credentialsAuthRoutes = authSessionsRoutes.grouped(User.credentialsAuthenticator())
        credentialsAuthRoutes.post(use: loginPostHandler)
        authSessionsRoutes.post("logout", use: logoutHandler)
        authSessionsRoutes.get("register", use: registerHandler)
        authSessionsRoutes.post("register", use: registerPostHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try req.content.decode(User.self)
        
        user.password = try Bcrypt.hash(user.password)
        
        return user.save(on: req.db).map { user.convertToPublic() }
    }
    
    func loginHandler(_ req: Request) -> EventLoopFuture<View> {
        let context: LoginContext
        
        if let error = req.query[Bool.self, at: "error"], error {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        
        return req.view.render("login", context)
    }
    
    func loginPostHandler(_ req: Request) -> EventLoopFuture<Response> {
        if req.auth.has(User.self) {
            return req.eventLoop.future(req.redirect(to: "/screening"))
        } else {
            let context = LoginContext(loginError: true)
            
            return req.view.render("login", context)
                .encodeResponse(for: req)
        }
    }
    
    func logoutHandler(_ req: Request) -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
    
    func registerHandler(_ req: Request) -> EventLoopFuture<View> {
        let context: RegisterContext
        
        if let message = req.query[String.self, at: "message"] {
            context = RegisterContext(message: message)
        } else {
            context = RegisterContext()
        }
        
        return req.view.render("register", context)
    }
    
    func registerPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        do {
            try RegisterData.validate(content: req)
        } catch let error as ValidationsError {
            let message = error.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Unknown error"
            let redirect = req.redirect(to: "/register?message=\(message)")
            
            return req.eventLoop.future(redirect)
        }
        
        let data = try req.content.decode(RegisterData.self)
        let password = try Bcrypt.hash(data.password)
        let user = User(firstName: data.firstName, lastName: data.lastName, username: data.username, password: password, role: data.role)
        
        return user.save(on: req.db).map {
            req.auth.login(user)
            
            return req.redirect(to: "/")
        }
    }
}

struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool
    
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

struct RegisterContext: Encodable {
    let title = "Register"
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
}

struct RegisterData: Content {
    // add more properties as required but make sure to update User model w/ relevant values
    let firstName: String
    let lastName: String
    let username: String // employeeID or patientID
    let role: Role
    let password: String
    let confirmPassword: String
}

extension RegisterData: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: .ascii)
        validations.add("lastName", as: String.self, is: .ascii)
        validations.add("username", as: String.self, is: .alphanumeric && .count(3...))
        validations.add("password", as: String.self, is: .count(8...))
    }
}
