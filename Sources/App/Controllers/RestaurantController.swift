//
//  RestaurantController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/11/06.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class RestaurantController: RouteCollection {
    // RouteCollection protocol
    func boot(router: Router) throws {
        
        let route = router.grouped(Constants.baseURL, "restaurant")
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        
        tokenAuthGroup.get("index", use: index)
        tokenAuthGroup.post(Restaurant.self ,use: create)
        tokenAuthGroup.get(Restaurant.parameter, use: getWithID)
        tokenAuthGroup.delete("delete", use: delete)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<RestaurantResponse>{
        let restaurants = Restaurant.query(on: req).all()
        
        return restaurants.flatMap { allRestaurants in
            return Future.map(on: req) { return RestaurantResponse(withSuccess: true, responseMessage: "All restaurants returned", returnedData: allRestaurants) }
        }
    }
    
    func create(_ req: Request, organisation: Restaurant) throws -> Future<Restaurant>{
        return organisation.save(on: req)
    }
    
    func getWithID(_ req: Request) throws -> Future<Restaurant>{
        return try req.parameters.next(Restaurant.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Restaurant.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
}
