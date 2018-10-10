//
//  StoreController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class StoreController{
    
    func index(_ req: Request) throws -> Future<[Store]>{
        return Store.query(on: req).all()
    }
    
    func create(_ req: Request, store: Store) throws -> Future<Store>{
        return store.save(on: req)
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
