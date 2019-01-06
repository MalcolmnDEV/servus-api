//
//  UserController.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import Vapor
import Crypto

struct LoginUser: Content {
    var id: UUID?
    var name: String
    var username: String
    var token: String
    
    init(id: UUID?, name: String, username: String, token: String) {
        self.id = id
        self.name = name
        self.username = username
        self.token = token
    }
}

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        
        /*
         Sign up User
         */
        router.post(Constants.baseURL + "signup", use: createUser)
        
        // Views
        router.get("/register", use: getRegisterView)
        router.get("/login", use: getLoginView)
        
        /*
         User group end points in this group have format user/...
         */
        let route = router.grouped(Constants.baseURL, "user")
        
        let basicAuthGroup = route.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
        basicAuthGroup.post("/login", use: loginUser)
//        route.post("/login", use: loginUser)
        
        let tokenAuthGroup = route.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())
        tokenAuthGroup.post("index", use: index)
        tokenAuthGroup.delete("delete", use: delete)
        tokenAuthGroup.get(UUID.parameter, use: getWithID)
    }
    
    func index(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
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
    
    func createUser(_ req: Request) throws -> Future<LoginUser> {
        return try req.content.decode(User.self).flatMap(to: LoginUser.self) { user in
            let passwordHash = try req.make(BCryptDigest.self).hash(user.password)
            user.password = passwordHash
            return user.save(on: req).flatMap(to: LoginUser.self) { user in
                let token = try Token.generate(for: user)
                return Future.map(on: req) { return LoginUser(id: user.id, name: user.name, username: user.username, token: token.token) }
            }
        }
    }
    
    func getLoginView(_ req: Request) throws -> Future<View>{
        return try req.view().render("login")
    }
    
    func loginUser(_ req: Request) throws -> Future<LoginUser> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req).flatMap(to: LoginUser.self) { token in 
            return Future.map(on: req) { return LoginUser(id: user.id, name: user.name, username: user.username, token: token.token) }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            return user.delete(on: req)
            }.transform(to: .ok)
    }
    
    func getWithID(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        return Future.map(on: req) { return user.convertToPublic() }
    }
    
    func resetPassword(_ req: Request) throws -> Future<HTTPStatus> {
        let emailAddress = try req.parameters.next(String.self)
        return MailManager.shared.sendEmailTo(emailAddress: emailAddress, usingEmail: .Support, usingRequest: req)
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
