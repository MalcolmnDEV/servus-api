//
//  cmsController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/10/11.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class CMSController: RouteCollection{
    
    func boot(router: Router) throws {
        
        router.get("/crud", use: getCRUDView)

    }
    
    func getCRUDView(_ req: Request) throws -> Future<View>{
        return try req.view().render("crud")
    }
}
