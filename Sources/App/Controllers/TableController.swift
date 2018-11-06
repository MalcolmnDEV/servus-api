//
//  TableViewController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/27.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class TableController: RouteCollection{
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "table")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Table.self ,use: create)
        tokenAuthGroup.get(Table.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<[Table]>{
        return Table.query(on: req).all()
    }
    
    func create(_ req: Request, organisation: Table) throws -> Future<Table>{
        return organisation.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Table>{
        return try req.parameters.next(Table.self)
    }
    
    func occupyTable(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Table.self).flatMap { table in
            return try req.content.decode(Table.self).flatMap { tableform in
                table.status = TableStatus.occupied
                return table.save(on: req).map { _ in
                    return Response(withSuccess: true, responseMessage: "Occupied Table", returnedData: table)
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Table.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
}

