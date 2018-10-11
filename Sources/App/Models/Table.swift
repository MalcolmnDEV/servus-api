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
    var tableNumber: Int
    
    init(id: Int? = nil, tableNumber: Int) {
        self.id = id
        self.tableNumber = tableNumber
    }
}

struct migrateTableModel: PostgreSQLMigration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Table.self, on: connection) { builder in
            builder.field(for: \.tableNumber)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Table.self, on: conn) { builder in
            builder.deleteField(for: \.tableNumber)
        }
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Table: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Table: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Table: Parameter { }
