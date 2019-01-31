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
        
        tokenAuthGroup.get("qr_code", String.parameter, use: getRestaurantFromQR)
        
        tokenAuthGroup.get(Restaurant.parameter, "menu", use: getRestaurantAndMenu)
        
        tokenAuthGroup.get("nearby/", Double.parameter, Double.parameter , use: getNearbyRestaurants)
    }
    
    // Controller Functions
    func index(_ req: Request) throws -> Future<RestaurantResponse>{
        let restaurants = Restaurant.query(on: req).all()
        
        return restaurants.flatMap { allRestaurants in
            return Future.map(on: req) { return RestaurantResponse(withSuccess: true, responseMessage: "All restaurants returned", returnedData: allRestaurants) }
        }
    }
    
    func create(_ req: Request, obj: Restaurant) throws -> Future<Restaurant>{

        return obj.save(on: req).always {
            // every restaurant must have a menu so when a new restaurant is created -> create an empty menu and then from there add items to the menu
            let menuObj = Menu(restaurantID: obj.id!)
            menuObj.save(on: req).always {
                // async when the save is completed
                
                obj.menu_id = menuObj.id!
                obj.save(on: req).always {
                    
                }
            }
        }
    }
    
    func getWithID(_ req: Request) throws -> Future<Restaurant>{
        return try req.parameters.next(Restaurant.self)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Restaurant.self).flatMap { temp in
            return temp.delete(on: req)
            }.transform(to: .ok)
    }
    
    func getRestaurantFromQR(_ req: Request) throws -> Future<Restaurant> {
        return try Restaurant.query(on: req).filter(\.qr_code_hex == req.parameters.next(String.self)).first().unwrap(or: Abort.init(.notFound))
    }
    
    func getRestaurantAndMenu(_ req: Request) throws -> Future<RestaurantMenuResponse> {
        return try req.parameters.next(Restaurant.self).flatMap(to: RestaurantMenuResponse.self) { restaurant in
            return try restaurant.menu.query(on: req).first().flatMap { menu in
                return try menu?.menu_items.query(on: req).all().map { items in
                    
                    return RestaurantMenuResponse(withSuccess: true, responseMessage: "Fetch successful", restaurant: restaurant, menu: Menu.Full(id: menu?.id, restaurantID: (menu?.restaurantID)!, items: items))
                    
                    } ?? Future.map(on: req) { return RestaurantMenuResponse(withSuccess: false, responseMessage: "Could not find restaurant and its menu", restaurant: nil, menu: nil) }  
            }
        }
    }
    
    func getNearbyRestaurants(_ req: Request) throws -> Future<RestaurantResponse> {
        let restaurants = Restaurant.query(on: req).all()
        
        return restaurants.flatMap { allRestaurants in
            return Future.map(on: req) { return RestaurantResponse(withSuccess: true, responseMessage: "All nearby restaurants returned", returnedData: allRestaurants) }
        }
    }
}
