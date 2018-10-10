//
//  OrderController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderController{
    
    func index(_ req: Request) throws -> Future<[Order]>{
        return Order.query(on: req).all()
    }
    
    func create(_ req: Request, order: Order) throws -> Future<Order>{
        return order.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Order>{
        return try req.parameters.next(Order.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Order.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
}
