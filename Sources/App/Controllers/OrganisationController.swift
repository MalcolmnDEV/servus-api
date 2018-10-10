//
//  OrganisationController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrganisationController{
    
    func index(_ req: Request) throws -> Future<[Organisation]>{
        return Organisation.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Organisation>{
        return try req.content.decode(Organisation.self).flatMap { temp in
            return temp.save(on: req)
        }
    }
    
    func getWithID(_ req: Request) throws -> Future<Organisation>{
        return try req.parameters.next(Organisation.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Organisation.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
}
