//
//  OrganisationController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/04.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Crypto

final class OrganisationController: RouteCollection{
    
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "organisation")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Organisation.self ,use: create)
        tokenAuthGroup.get(Organisation.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
    }

    // Controller Functions
    func index(_ req: Request) throws -> Future<[Organisation]>{
        return Organisation.query(on: req).all()
    }
    
    func create(_ req: Request, organisation: Organisation) throws -> Future<Organisation>{
        return organisation.save(on: req)
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
