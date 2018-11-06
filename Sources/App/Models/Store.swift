//
//  Store.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Store: PostgreSQLModel, Codable {
    var id: Int?
    var menu: Menu
    
    init(id: Int? = nil, menu: Menu) {
        self.id = id
        self.menu = menu
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Store: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Store: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Store: Parameter { }
