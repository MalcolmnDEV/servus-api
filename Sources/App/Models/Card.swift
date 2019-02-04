//
//  Card.swift
//  App
//
//  Created by Malcolmn Roberts on 2019/02/04.
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Card: PostgreSQLModel, Codable {

    var id: Int?
    var name: String
    var number: String
    var user_id: User.ID
    
    init(id: Int?, name: String, number: String, userID: User.ID) {
        self.id = id
        self.name = name
        self.number = number
        self.user_id = userID
    }
}

extension Card {
    var user: Parent<Card, User> {
        return parent(\.user_id)
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Card: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Card: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Card: Parameter { }

