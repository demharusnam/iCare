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
        let appointmentRoutes = routes.grouped("appointments")
        appointmentRoutes.get(use: indexHandler)
        appointmentRoutes.get(":appointmentID",use: appointmentHandler) //specific appointments per user will need to add a different endpoint
        appointmentRoutes.get("new", use: createAppointmentHandler)
        appointmentRoutes.post("new", use: createAppointmentPostHandler)
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
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        Appointment.query(on: req.db).all().flatMap { appointments in
            let context = IndexContext(
                title: "Appointments",
                appointments: appointments)
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
    
    // MARK: - CREATE APPOINTMENT BUTTONS AND HANDLERS
    func createAppointmentHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("newAppointment")
    }
    
    func createAppointmentPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateAppointmentData.self)
        let date = "\(data.date) at \(data.time)"
        
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let appointment = Appointment(
            name: data.name,
            description: data.description,
            date: date,
            userID: userID)
        
        return appointment.save(on: req.db).transform(to: req.redirect(to: "/appointments"))
    }
    
}

// MARK: - STRUCTS
struct CreateAppointmentData: Content {
    let name: String
    let description: String
    let date: String
    let time: String
}

struct IndexContext: Encodable {
    let title: String
    let appointments: [Appointment]
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

struct CreateAppointmentContext: Encodable {
    let title = "New Appointment"
    let users: [User]
}

//MARK: QUERIES
//Table.query(on: req.db).all() equivalent to SELECT * FROM TABLE
//Table.find(req.parameters.get("tableID"), on: req.db) Queries for an entry with the specific ID. returns one entry
