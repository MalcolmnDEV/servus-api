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
        tokenAuthGroup.get(Organisation.parameter, "restaurants", use: getRestaurants)
    }

    //MARK:- Controller Default Functions
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
    
    // MARK: - Extra functions
    func getRestaurants(_ req: Request) throws -> Future<Organisation.Full> {
        
        return try req.parameters.next(Organisation.self).flatMap(to: Organisation.Full.self) { temp in
            return try temp.restaurants.query(on: req).all().map { items in
                Organisation.Full(id: temp.id, name: temp.name, address: temp.address, items: items)
            }
        }
        
    }
    
//    func getMenuItems(_ req: Request) throws -> Future<Menu.Full>{
//        
//        return try req.parameters.next(Menu.self).flatMap(to: Menu.Full.self) { menu in
//            return try menu.menu_items.query(on: req).all().map { items in
//                Menu.Full(id: menu.id, restaurantID: menu.restaurantID, items: items)
//            }
//        }
//    }
    
}
