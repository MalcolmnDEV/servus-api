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
        
        let route = router.grouped(Constants.baseURL, "Menu")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Menu.self ,use: create)
        tokenAuthGroup.get(Menu.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
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
}
