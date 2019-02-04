//
//  User.swift
//  App
//
//  Created by Malcolmn Roberts on 2018/09/23.
//

import FluentPostgreSQL
import Vapor
import Authentication
import Reset
import Leaf
import MailCore
import Sugar
import JWTKeychain


final class User: Codable, HasReadablePassword, HasReadableUsername {
    static var readablePasswordKey: KeyPath<User, String> = \.password
    
    static var readableUsernameKey: KeyPath<User, String> = \.email
    
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var email: String
    var passwordChangeCount: Int
    
    init(name: String, username: String, password: String, email: String, passwordChangeCount: Int = 0) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
        self.passwordChangeCount = passwordChangeCount
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var email: String
        
        init(id: UUID?, name: String, username: String, email: String) {
            self.id = id
            self.name = name
            self.username = username
            self.email = email
        }
    }
}

extension User {
    
    var user_cards: Children<User, Card> {
        return children(\.user_id)
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}

extension User: Migration {
    
}

extension User: Parameter {}
extension User.Public: Content {}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, email: email)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", username: "admin", password: hashedPassword, email: "admin@servus.co.za", passwordChangeCount: 0)
        return user.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Future.map(on: connection) {}
    }
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}

extension User: PasswordResettable {
    
    typealias Context = ResetPasswordContext
    
    public struct RequestReset: RequestCreatable, Decodable, HasReadableUsername {
        static let readableUsernameKey = \RequestReset.username
        public let username: String
    }
    
    public struct ResetPassword: RequestCreatable, Decodable, HasReadablePassword {
        static let readablePasswordKey = \ResetPassword.password
        public let password: String
    }
    
    internal struct ResetPasswordEmail: Codable {
        let url: String
        let expire: Int
    }
    
    public func sendPasswordReset(
        url: String,
        token: String,
        expirationPeriod: TimeInterval,
        context: ResetPasswordContext,
        on req: Request
        ) throws -> Future<Void> {
        let mailgun = try req.make(Mailer.self)
        let projectConfig = try req.make(AppConfig.self)
        let emailData = ResetPasswordEmail(url: url, expire: Int(expirationPeriod / 60))
        
        return try req
            .make(LeafRenderer.self)
            .render(ViewPath.Reset.resetPasswordEmail, emailData)
            .map(to: String.self) { view in
                String(bytes: view.data, encoding: .utf8) ?? ""
            }
            .flatMap(to: Mailer.Result.self) { html in
                try mailgun.send(Mailer.Message(
                    from: projectConfig.resetPasswordEmail.fromEmail,
                    to: self.email,
                    subject: projectConfig.resetPasswordEmail.subject,
                    text: "Please turn on html to view this email.",
                    html: html
                ), on: req)
            }
            .transform(to: ())
    }
    
    // Multiple matches, so need to specify one here.
    public static func authenticate(
        using payload: User.JWTPayload,
        on connection: DatabaseConnectable
        ) throws -> EventLoopFuture<User?> {
        guard let id = ID(payload.sub.value) else {
            throw AuthenticationError.malformedPayload
        }
        
        return find(id, on: connection)
    }
}

extension User: JWTCustomPayloadKeychainUserType {
    func convertToPublic(on req: Request) throws -> EventLoopFuture<User.Public> {
        return req.future( self.convertToPublic() )
    }
    

    typealias JWTPayload = ModelPayload<User>
    typealias Login = UserLogin
    typealias Registration = UserRegistration
    typealias Update = UserUpdate
    
    struct UserLogin: HasReadablePassword, HasReadableUsername {
        static let readablePasswordKey = \UserLogin.password
        static let readableUsernameKey = \UserLogin.email
        
        let email: String
        let password: String
    }
    
    struct UserPublic: Content {
        let email: String
        let name: String
    }
    
    struct UserRegistration: HasReadablePassword, HasReadableUsername {
        static let readablePasswordKey = \UserRegistration.password
        static let readableUsernameKey = \UserRegistration.email
        
        let email: String
        let name: String
        let customerIds: String
        let password: String
        let username: String
    }
    
    struct UserUpdate: Decodable, HasUpdatableUsername, HasUpdatablePassword {
        static let oldPasswordKey = \UserUpdate.oldPassword
        static let updatablePasswordKey = \UserUpdate.password
        static let updatableUsernameKey = \UserUpdate.email
        
        let email: String?
        let name: String?
        let password: String?
        let oldPassword: String?
        
        var username: String? {
            return email
        }
    }
    
    convenience init(_ registration: UserRegistration) throws {
        try self.init(name: registration.name, username: registration.username, password: User.hashPassword(registration.password), email: registration.email)
    }
    
    func update(with updated: UserUpdate) throws {
        if let email = updated.email {
            self.email = email
        }
        
        if let password = updated.password {
            self.password = try User.hashPassword(password)
            self.passwordChangeCount += 1
        }
        
        if let name = updated.name {
            self.name = name
        }
    }
}
