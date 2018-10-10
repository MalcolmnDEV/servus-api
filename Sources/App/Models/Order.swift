//
//  Order.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Order: PostgreSQLModel {
    var id: Int?
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Order: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Order: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Order: Parameter { }
