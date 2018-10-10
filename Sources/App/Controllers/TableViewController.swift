//
//  TableViewController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/27.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class TableViewController{
    func index(_ req: Request) throws -> Future<[Table]>{
        return Table.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> String{
        return "yay it works"
    }
    
    func getWithID(_ req: Request) throws -> String{
        return "yay get table works"
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Table.self).flatMap { table in
            return table.delete(on: req)
        }.transform(to: .ok)
    }
}

