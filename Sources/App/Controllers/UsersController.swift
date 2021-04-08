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
        let usersRoutes = routes.grouped("api", "users")
        usersRoutes.get(use: getAllHandler)
        usersRoutes.get(":userID", use: getHandler)
        usersRoutes.get(":userID","appointments", use: getAppointmentsHandler)
        
        let authSessionsRoutes = routes.grouped(User.sessionAuthenticator())
        authSessionsRoutes.get(use: loginHandler)
        authSessionsRoutes.post("logout", use: logoutHandler)
        authSessionsRoutes.get("register", use: registerHandler)
        authSessionsRoutes.post("register", use: registerPostHandler)
        
        let credentialsAuthRoutes = authSessionsRoutes.grouped(User.credentialsAuthenticator())
        credentialsAuthRoutes.post(use: loginPostHandler)
        
        let protectedRoutes = authSessionsRoutes.grouped(User.redirectMiddleware(path: "/"))
        protectedRoutes.get("profile", use: profileHandler)
        
        // register protected controllers (ANYTHING THAT REQUIRES USER DATA)
        let screeningController = ScreeningController()
        try protectedRoutes.register(collection: screeningController)
        
        let appointmentController = AppointmentController()
        try protectedRoutes.register(collection: appointmentController)
        
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
    
    //returning users with http requests
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAppointmentsHandler(_ req: Request) -> EventLoopFuture<[Appointment]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$appointments.get(on: req.db)
            }
    }
    
    //MARK: PROFILES HANDLERS
    func profileHandler(_ req: Request) throws -> EventLoopFuture<View> {
       
        let user = try req.auth.require(User.self)
        let context = ProfileContext(
            title: "Profile",
            user: user
        )
        return req.view.render("profile", context)
    
        
        /*
         First Name Last Name:
         Username:
         Role:
         
         */
    
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


//profile
struct ProfileContext: Encodable {
    let title: String
    let username: String
    let firstName: String
    let lastName: String
    let role: Role
    init(title: String, user: User){
        self.title = title
        self.username = user.username
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.role = user.role
    }
}
