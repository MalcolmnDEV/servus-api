//
//  Order.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

enum OrderStatus: Int, Codable {
    case created
    case pending
    case done
}

final class Order: PostgreSQLModel, Codable {
    var id: Int?
    var user_id: User.ID
    var fluentCreatedAt: Date?
    var fluentUpdatedAt: Date?
    var fluentDeletedAt: Date?
    var order_status: OrderStatus
    var order_items: [Menu_Item]
    var total: Double = 0.0
    
    init(id: Int? = nil, userID: User.ID, items: [Menu_Item]) {
        self.id = id
        self.user_id = userID
        self.order_status = OrderStatus(rawValue: 0)!
        self.order_items = items
        
        for item in items {
            self.total = self.total + item.price
        }
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Order: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Order: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Order: Parameter { }
