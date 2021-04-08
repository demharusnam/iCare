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
        let appointmentRoutes = routes.grouped("api","appointments")
        appointmentRoutes.get(use: getAllHandler)
        appointmentRoutes.post(use: createAppointmentHandler)
        appointmentRoutes.get(":appointmentID", use: getAppointmentHandler)
        appointmentRoutes.delete(":appointmentID", use: deleteAppointmentHandler)
        appointmentRoutes.get(":appointmentID", "user", use: getUserHandler)
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
}



struct CreateAppointmentData: Content {
    let name: String
    let description: String
    let date: String
    let userID: UUID
}

