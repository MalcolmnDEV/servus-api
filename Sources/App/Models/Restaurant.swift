//
//  Restaurant.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/11/05.
//

import FluentPostgreSQL
import Vapor
import CommonCrypto

struct ContactInfo: Codable {
    var number: String
    var email: String
    
    init(number: String, email:String) {
        self.number = number
        self.email = email
    }
}

final class Restaurant: PostgreSQLModel, Codable {
    var id: Int?
    var name: String
    var address: String
    var contactInfo: ContactInfo
    var organisationId: Organisation.ID
    var menu_id: Menu.ID?
    var qr_code_hex: String?
        
    init(id: Int? = nil, organisationId: Organisation.ID, name: String, address: String, number: String, email: String) {
        self.id = id
        self.organisationId = organisationId
        self.name = name
        self.address = address
        self.contactInfo = ContactInfo(number: number, email: email)
        
        self.qr_code_hex = self.MD5("\(self.id!)+\(self.address)")
    }
    
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
}

extension Restaurant {
    var organisation: Parent<Restaurant, Organisation> {
        return parent(\.organisationId)
    }
    
    var menu: Children<Restaurant, Menu> {
        return children(\.restaurantID)
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Restaurant: Migration {}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Restaurant: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Restaurant: Parameter { }
