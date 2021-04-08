import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let screeningController = ScreeningController()
    try app.register(collection: screeningController)
    
    let appointmentController = AppointmentController()
    try app.register(collection: appointmentController)

}
