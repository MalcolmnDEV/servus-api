//
//  Menu_Item.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

enum Course: Int, Codable {
    case starter
    case main
    case desert
}

final class Menu_Item: PostgreSQLModel, Codable {
    var id: Int?
    var title: String
    var course: Course
    var menuID: Menu.ID // parent ID
    
    init(id: Int? = nil, title: String, course:Course, menuID: Menu.ID) {
        self.id = id
        self.title = title
        self.course = course
        self.menuID = menuID
    }
}

extension Menu_Item {
    var menu: Parent<Menu_Item, Menu> {
        return parent(\.menuID)
    }
}



/// Allows `Todo` to be used as a dynamic migration.
extension Menu_Item: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Menu_Item: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Menu_Item: Parameter { }
