//
//  Restaurant.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/11/05.
//

import FluentPostgreSQL
import Vapor

struct ContactInfo: Codable {
    var number: String
    var email: String
    
    init(number: String, email:String) {
        self.number = number
        self.email = email
    }
}

final class Restaurant: PostgreSQLModel, Codable {
    var id: Int?
    var name: String
    var address: String
    var contactInfo: ContactInfo
    var organisationId: Organisation.ID
    var menu_id: Menu.ID?
        
    init(id: Int? = nil, organisationId: Organisation.ID, name: String, address: String, number: String, email: String) {
        self.id = id
        self.organisationId = organisationId
        self.name = name
        self.address = address
        self.contactInfo = ContactInfo(number: number, email: email)
    }
}

extension Restaurant {
    var organisation: Parent<Restaurant, Organisation> {
        return parent(\.organisationId)
    }
    
    var menu: Children<Restaurant, Menu> {
        return children(\.restaurantID)
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Restaurant: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Restaurant: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Restaurant: Parameter { }
