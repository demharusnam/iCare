//
//  CreateVisitor.swift
//  
//
//  Created by Mansur Ahmed on 2021-04-05.
//

import Fluent

struct CreateVisitor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visitor.schema)
            .id()
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visitor.schema)
            .delete()
    }
}
