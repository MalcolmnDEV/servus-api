//
//  Menu_Item.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

enum Course: Int, Codable {
    case starter // 0
    case main // 1
    case desert // 2
    case drink // 3
    case side // 4
}

enum Diet: Int, Codable {
    case vegeterian // 0
    case vegan // 1
    case cluten_free // 2
    case none // 3
}

struct SelectionGroup: Codable {
    
    struct SelectionOption: Codable {
        var id: Int?
        var title: String
        
        init(id: Int?, name: String) {
            self.id = id
            self.title = name
        }
    }
    
    var id: Int?
    var title: String
    var options: [SelectionOption]
    
    init(id: Int?, name: String, options: [SelectionOption]) {
        self.id = id
        self.title = name
        self.options = options
    }
}

final class Menu_Item: PostgreSQLModel, Codable {
    var id: Int?
    var title: String
    var course: Course
    var diet_group: Diet
    var menuID: Menu.ID // parent ID
    var price_with_vat: Double
    var price: Double
    var selection_groups: [SelectionGroup] = []
    
    init(id: Int? = nil, title: String, course:Course, menuID: Menu.ID, diet_group: Diet, item_price: Double) {
        self.id = id
        self.title = title
        self.course = course
        self.menuID = menuID
        self.diet_group = diet_group
        
        self.price = item_price
        self.price_with_vat = item_price * Constants.VAT
    }
}

extension Menu_Item {
    var menu: Parent<Menu_Item, Menu> {
        return parent(\.menuID)
    }
}

extension Menu_Item: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Menu_Item: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Menu_Item: Parameter { }
