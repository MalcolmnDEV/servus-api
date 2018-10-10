//
//  Organisation.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Organisation: PostgreSQLModel {
    var id: Int?
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Organisation: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Organisation: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Organisation: Parameter { }
