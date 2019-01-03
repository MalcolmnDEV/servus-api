//
//  MenuController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class MenuController: RouteCollection{
    
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "menu")
        let itemRoute = router.grouped(Constants.baseURL, "menu/item")
        
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        let tokenAuthGroupItem = itemRoute.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Menu.self ,use: create)
        tokenAuthGroup.get(Menu.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
        tokenAuthGroup.get("full", Menu.parameter, use: getMenuItems)
                
        // Menu Items
        tokenAuthGroupItem.get("index", use: indexItems)
        tokenAuthGroupItem.post(Menu_Item.self ,use: createItem)
        tokenAuthGroupItem.get(Menu_Item.parameter, use: getWithIDItem)
        tokenAuthGroupItem.delete("delete", use: deleteItem)
        
        itemRoute.get("/upload", use: getUploadView)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<[Menu]>{
        return Menu.query(on: req).all()
    }
    
    func create(_ req: Request, organisation: Menu) throws -> Future<Menu>{
        return organisation.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Menu>{
        return try req.parameters.next(Menu.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Menu.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
    func getMenuItems(_ req: Request) throws -> Future<Menu.Full>{
        
        return try req.parameters.next(Menu.self).flatMap(to: Menu.Full.self) { menu in
            return try menu.menu_items.query(on: req).all().map { items in
                Menu.Full(id: menu.id, restaurantID: menu.restaurantID, items: items)
            }
        }
    }
    
    // Menu Items Controller Functions
    
    func getUploadView(_ req: Request) throws -> Future<View>{
        return try req.view().render("upload")
    }
    
    func indexItems(_ req: Request) throws -> Future<[Menu_Item]>{
        return Menu_Item.query(on: req).all()
    }
    
    func createItem(_ req: Request, organisation: Menu_Item) throws -> Future<Menu_Item>{
        return organisation.save(on: req)
    }
    
    func getWithIDItem(_ req: Request) throws -> Future<Menu_Item>{
        return try req.parameters.next(Menu_Item.self)
    }
    
    func deleteItem(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Menu_Item.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
    // MARK: - Extras
//    func addMenuItem(_ req: Request) throws -> Future<Menu> {
//        guard let objectId = req.query[Int.self, at: "menuId"] else {
//            throw Abort(.badRequest)
//        }
//        
//        return Menu.find(objectId, on: req).map(to: Menu.self) { menu in
//            guard let menu = menu else { throw Abort.init(HTTPStatus.notFound) }
//            menu.addItem(item: req.parameters.next(Menu_Item.self))
//            return menu.save(on: req)
//        }
//    }
}

