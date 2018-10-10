//
//  InvoiceController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class InvoiceController{
    
    func index(_ req: Request) throws -> Future<[Invoice]>{
        return Invoice.query(on: req).all()
    }
    
    func create(_ req: Request, invoice: Invoice) throws -> Future<Invoice>{
        return invoice.save(on: req)
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
