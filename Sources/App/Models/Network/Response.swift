//
//  Response.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/15.
//

import Foundation
import Vapor
import Codability

struct Response: Codable {
    var success: Bool
    var message: String
    var data: AnyCodable
    
    init(withSuccess: Bool, responseMessage: String, returnedData: AnyCodable) {
        self.success = withSuccess
        self.message = responseMessage
        self.data = returnedData
    }
}

extension Response: Content { } 

struct RestaurantResponse: Codable {
    var success: Bool
    var message: String
    var restaurants: [Restaurant]
    var menu: [Menu]?
    
    init(withSuccess: Bool, responseMessage: String, returnedData: [Restaurant]) {
        self.success = withSuccess
        self.message = responseMessage
        self.restaurants = returnedData
    }
}

extension RestaurantResponse: Content { } 

struct RestaurantMenuResponse: Codable {
    var success: Bool
    var message: String
    var restaurant: Restaurant?
    var menu: Menu.Full?
    
    init(withSuccess: Bool, responseMessage: String, restaurant: Restaurant?, menu: Menu.Full?) {
        self.success = withSuccess
        self.message = responseMessage
        self.restaurant = restaurant
        self.menu = menu
    }
}

extension RestaurantMenuResponse: Content { } 
