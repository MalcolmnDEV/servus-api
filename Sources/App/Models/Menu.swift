//
//  Menu.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor

//struct FullMenu {
//    var menu: Menu
//    var menu_items: [Menu_Item]
//    
//    init(nMenu: Menu, _ req: Request) {
//        self.menu = nMenu
//        
//        self.menu_items = try nMenu.menu_items.query(on: req).all().wait()
//    }
//}



final class Menu: PostgreSQLModel, Codable {
    var id: Int?
    var restaurantID: Restaurant.ID // parent id
    
    init(id: Int? = nil, restaurantID: Restaurant.ID) {
        self.id = id
        self.restaurantID = restaurantID
    }
    
    final class Full: Content {
        var id: Int?
        var restaurantID: Restaurant.ID // parent id
        var menuItems: [Menu_Item]
        
        init(id: Int? = nil, restaurantID: Restaurant.ID, items: [Menu_Item]) {
            self.id = id
            self.restaurantID = restaurantID
            self.menuItems = items
        }
    }
}

extension Menu {
    var Restaurant: Parent<Menu, Restaurant> {
        return parent(\.restaurantID)
    }
    
    var menu_items: Children<Menu, Menu_Item> {
        return children(\.menuID)
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Menu: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Menu: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Menu: Parameter { }
