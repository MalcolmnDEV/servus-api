//
//  Menu_Item.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Menu_Item: PostgreSQLModel {
    var id: Int?
    
    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Menu_Item: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Menu_Item: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Menu_Item: Parameter { }
