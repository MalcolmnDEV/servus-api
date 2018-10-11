//
//  UserController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import Vapor
import Crypto

final class UserController {
    func index(_ req: Request) throws -> Future<[User]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.authTokens.query(on: req).first().flatMap(to: [User].self) { userTokenType in
            guard (userTokenType?.token) != nil else { throw Abort.init(HTTPResponseStatus.notFound) }
            return User.query(on: req).all()
        }
    }
    
//    func viewAll(_ req: Request) throws -> Future<View>{
//        return User.query(on: req).all().flatMap { users in
//            let data = ["userlist": users]
//            return try req.view().render("userview", data)
//        }
//    }
    
    func getRegisterView(_ req: Request) throws -> Future<View>{
        return try req.view().render("register")
    }
    
    func createUser(_ req: Request) throws -> Future<User.Public> {
//        return try request.content.decode(User.self).flatMap(to: User.PublicUser.self) { user in
//            let passwordHashed = try request.make(BCryptDigest.self).hash(user.password)
//            let newUser = User(username: user.username, password: passwordHashed)
//            return newUser.save(on: request).flatMap(to: User.PublicUser.self) { createdUser in
//                let accessToken = try Token.createToken(forUser: createdUser)
//                return accessToken.save(on: request).map(to: User.PublicUser.self) { createdToken in
//                    let publicUser = User.PublicUser(username: createdUser.username, token: createdToken.token)
//                    return publicUser
//                }
//            }
//        }
        
        return try req.content.decode(User.self).flatMap(to: User.Public.self) { user in
            let passwordHash = try req.make(BCryptDigest.self).hash(user.password)
            user.password = passwordHash
            return user.save(on: req).convertToPublic()
        }
    }
    
    func getLoginView(_ req: Request) throws -> Future<View>{
        return try req.view().render("login")
    }
    
    func loginUser(_ req: Request) throws -> Future<Token> {
//        return try request.content.decode(User.self).flatMap(to: User.self) { user in
//            let passwordVerifier = try request.make(BCryptDigest.self)
//            return User.authenticate(username: user.username, password: user.password, using: passwordVerifier, on: request).unwrap(or: Abort.init(HTTPResponseStatus.unauthorized))
//        }
        
//        return try req.content.decode(User.LoginUser.self).flatMap(to: User.self) { user in
//            let psVerifier = try req.make(BCryptDigest.self)
//            let basicAuth = BasicAuthorization(username: user.username, password: user.password)
//
//            return User.authenticate(using: basicAuth, verifier: psVerifier, on: req).unwrap(or: Abort.init(.unauthorized))
//            let authUser = User.authenticate(using: basicAuth, verifier: psVerifier, on: req).unwrap(or: Abort.init(.unauthorized))
//            let token = try Token.generate(for: user)
//            return token.save(on: req)
            
//            return User.LoginUser(user: authUser.flatMap(to: User.Public, <#(T) throws -> EventLoopFuture<T>#>), token: token)
            
//            return try User.authenticate(using: basicAuth, verifier: psVerifier, on: req)
//            let tempUser = User.authenticate(username: user.username, password: user.password, using: psVerifier, on: req)
//            let token = try Token.generate(for: tempUser)
//            return token.save(on: req)
//        }
        
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
            }.transform(to: .ok)
    }
}

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's full name.
    var firstName: String
    var lastName: String
    
    /// User's email address.
    var email: String
    var username: String
    
    /// User's desired password.
    var password: String
    
    /// User's password repeated to ensure they typed it correctly.
    var verifyPassword: String
}

/// Public representation of user data.
struct UserResponse: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's full name.
    var firstName: String
    var lastName: String
    
    var username: String
    
    /// User's email address.
    var email: String
}
