//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-07.
//

import Vapor
import Fluent

struct AppointmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appointmentApiRoutes = routes.grouped("api","appointments")
        appointmentApiRoutes.get(use: getAllHandler)
        appointmentApiRoutes.post(use: createAppointmentHandler)
        appointmentApiRoutes.get(":appointmentID", use: getAppointmentHandler)
        appointmentApiRoutes.delete(":appointmentID", use: deleteAppointmentHandler)
        appointmentApiRoutes.get(":appointmentID", "user", use: getUserHandler)

        
        let appointmentRoutes = routes.grouped("appointments")
        appointmentRoutes.get(use: indexHandler)
        appointmentRoutes.get(":appointmentID",use: appointmentHandler) //specific appointments per user will need to add a different endpoint
        
        routes.get("users", ":userID", use: userHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Appointment]> {
      Appointment.query(on: req.db).all()
    }
    
    func createAppointmentHandler(_ req: Request) throws -> EventLoopFuture<Appointment> {
        let data = try req.content.decode(CreateAppointmentData.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let date = dateFormatter.date(from: data.date)
        let appointment = Appointment(
            name: data.name,
            description: data.description,
            date: date!,
            userID: data.userID)
        return appointment.save(on: req.db).map {appointment}
    }
    
    func getAppointmentHandler(_ req: Request) -> EventLoopFuture<Appointment> {
        Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func deleteAppointmentHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { appointment in
                appointment.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { appointment in
                appointment.$user.get(on: req.db)
            }
    }
    
    
//MARK: WE NEED TO QUERY ON THE THE APPOINTMENTS TABLE WITH THE CURRENT USER ID: THE LOGGED IN USERS ID
//    idk how to do that need help with that
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        Appointment.query(on: req.db).all().flatMap { appointments in
            let appointmentData = appointments.isEmpty ? nil : appointments
            let context = IndexContext(
                title: "Appointments",
                appointments: appointmentData)
            return req.view.render("appointments", context)
        }
        
    }
    
    func appointmentHandler(_ req: Request) -> EventLoopFuture<View> {
        Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { appointment in
                appointment.$user.get(on: req.db).flatMap { user in
                    let context = AppointmentContext (title: appointment.name, appointment: appointment, user: user)
                    print(appointment.date)
                    return req.view.render("appointment", context)
                }
            }
    }
    
    func userHandler(_ req: Request) -> EventLoopFuture<View> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$appointments.get(on: req.db).flatMap { appointments in
                    let context = UserContext(title: user.firstName, user: user, appointments: appointments)
                    return req.view.render("user", context)
                }
            }
    }
}

//MARK: STRUCTS

struct CreateAppointmentData: Content {
    let name: String
    let description: String
    let date: String
    let userID: UUID
}

struct IndexContext: Encodable {
    let title: String
    let appointments: [Appointment]?
}

struct AppointmentContext: Encodable {
    let title: String
    let appointment: Appointment
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let appointments: [Appointment]
}


//MARK: QUERIES
//Table.query(on: req.db).all() equivalent to SELECT * FROM TABLE
//Table.find(req.parameters.get("tableID"), on: req.db) Queries for an entry with the specific ID. returns one entry

