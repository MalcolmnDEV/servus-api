//
//  OrderResponse.swift
//  App
//
//  Created by Malcolmn Roberts on 2019/02/04.
//

import Foundation
import Vapor

//struct OrderParameters: Parameter {
//    
//    var items: [Menu_Item]
//    var userID: User.ID
//    
//    init(user_id: User.ID, menu_items: [Menu_Item]) {
//        self.userID = user_id
//        self.items = menu_items
//    }
//}
//
//extension OrderParameters: Content { } 

struct OrderResponse: Codable {
    var success: Bool
    var message: String
    var order: Order?
    
    init(withSuccess: Bool, responseMessage: String, order: Order?) {
        self.success = withSuccess
        self.message = responseMessage
        self.order = order
    }
}

extension OrderResponse: Content { } 
