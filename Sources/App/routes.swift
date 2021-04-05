import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> String in
        return "Hello World"
    }
    
    let usersController = UsersController()
    try app.register(collection: usersController)
}
