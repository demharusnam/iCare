//
//  Role.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-12.
//

import Vapor
    
enum Role: String {
    // add more as required
    case doctor = "Doctor"
    case patient = "Patient"
    case visitor = "Visitor"
    case nurse = "Nurse"
    case employee = "Employee" // general employee?
    
    var clearance: Int {
        switch self {
        case .doctor: return 1
        case .nurse: return 2
        case .patient: return 3
        case .visitor: return 4
        default: return -1 // error/unspecified clearance
        }
    }
}

extension Role: Content {}
