//
//  Store.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Store: PostgreSQLModel {
    var id: Int?
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Store: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Store: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Store: Parameter { }
