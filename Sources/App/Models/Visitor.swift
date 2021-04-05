//
//  Visitor.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Foundation
import Vapor
import Fluent

final class Visitor: Model, Content {
    static var schema = "visitors"
    
    @ID(key: .id)
    var id: UUID?
}
