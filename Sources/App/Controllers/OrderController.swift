//
//  OrderController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderController: RouteCollection{
    
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "order")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Order.self ,use: create)
        tokenAuthGroup.get(Order.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
        
        tokenAuthGroup.put(Order.parameter, use: updateOrder)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<[Order]>{
        return Order.query(on: req).all()
    }
    
    func create(_ req: Request, organisation: Order) throws -> Future<Order>{
        return organisation.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Order>{
        return try req.parameters.next(Order.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Order.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
    func updateOrder(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Order.self).flatMap { temp in
            return temp.update(on: req)
            }.transform(to: .ok)
    }
    
}
