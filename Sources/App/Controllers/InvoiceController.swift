//
//  InvoiceController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class InvoiceController: RouteCollection{
    
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "Invoice")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Invoice.self ,use: create)
        tokenAuthGroup.get(Invoice.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<[Invoice]>{
        return Invoice.query(on: req).all()
    }
    
    func create(_ req: Request, organisation: Invoice) throws -> Future<Invoice>{
        return organisation.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Invoice>{
        return try req.parameters.next(Invoice.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Invoice.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
}
