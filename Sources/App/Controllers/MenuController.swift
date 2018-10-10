//
//  MenuController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class MenuController{
    
    func index(_ req: Request) throws -> Future<[Menu]>{
        return Menu.query(on: req).all()
    }
    
    func create(_ req: Request, menu: Menu) throws -> Future<Menu>{
        return menu.save(on: req)
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
