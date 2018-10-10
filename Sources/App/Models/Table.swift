//
//  Table.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Table: PostgreSQLModel {
    var id: Int?
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Table: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Table: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Table: Parameter { }
