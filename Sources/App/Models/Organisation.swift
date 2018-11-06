//
//  Organisation.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

final class Organisation: PostgreSQLModel, Codable {
    var id: Int?
    var name: String
    var address: String
    
    init(id: Int? = nil, name: String, address:String) {
        self.id = id
        self.name = name
        self.address = address
    }
}

extension Organisation {
    var restaurants: Children<Organisation, Restaurant> {
        return children(\.organisationId)
    }
}

struct migrateOrganisationModel: PostgreSQLMigration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Organisation.self, on: connection) { builder in
            builder.field(for: \.address)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Organisation.self, on: conn) { builder in
            builder.deleteField(for: \.address)
        }
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Organisation: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {

        return Database.update(Organisation.self, on: connection, closure: { builder in
            builder.field(for: \.name)
            builder.field(for: \.address)
        })


//        return Database.create(Organisation.self, on: connection) { builder in
//            builder.field(for: \.id, isIdentifier: true)
//            builder.field(for: \.name, type: .string)
////            builder.field(for: \.name , to: \Organisation.name)
////            builder.field(for: \.address, to: \Organisation.address)
//        }
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Organisation: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Organisation: Parameter { }
