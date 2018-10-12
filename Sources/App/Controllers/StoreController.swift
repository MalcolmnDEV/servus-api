//
//  StoreController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class StoreController: RouteCollection{
    
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "store")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Store.self ,use: create)
        tokenAuthGroup.get(Store.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<[Store]>{
        return Store.query(on: req).all()
    }
    
    func create(_ req: Request, obj: Store) throws -> Future<Store>{
        return obj.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Store>{
        return try req.parameters.next(Store.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Store.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
}
