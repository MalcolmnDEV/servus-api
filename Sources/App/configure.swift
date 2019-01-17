import Vapor
import Leaf
import Authentication
import FluentPostgreSQL
import MailCore
import Reset
import Sugar

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    //    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    services.register(Router.self) { container -> EngineRouter in
        let router = EngineRouter.default()
        try router.useResetRoutes(User.self, on: container)
        try routes(router)
        return router
    }
    
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    let hostname = Environment.get(EnvironmentKey.PSQL.hostname) ?? "localhost"
    let port: Int
    if let testPort = Environment.get("DATABASE_PORT") {
        port = Int(testPort) ?? 5432
    } else {
        port = 5432
    }
    
    let username = Environment.get("DATABASE_USER") ?? "malcolmnroberts"
    let db = Environment.get(EnvironmentKey.PSQL.database) ?? "servus_dev_db"
    let pw = Environment.get(EnvironmentKey.PSQL.password) ?? nil
    
    let database = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: hostname,
                                                                       port: port,
                                                                       username: username,
                                                                       database: db,
                                                                       password: pw))
    
    
    // Configure a PostgreSQL database
        
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    databases.enableLogging(on: .psql)
    //    databases.enableLogging(on: .sqlite)
    //    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Order.self, database: .psql)
    migrations.add(model: Invoice.self, database: .psql)
    migrations.add(model: Table.self, database: .psql)
    migrations.add(model: Menu.self, database: .psql)
    migrations.add(model: Menu_Item.self, database: .psql)
    migrations.add(model: Store.self, database: .psql)
    migrations.add(model: Organisation.self, database: .psql)
    migrations.add(model: Restaurant.self, database: .psql)
    
    
    //Migrations
//    migrations.add(migration: migrateOrganisationModel.self, database: .psql)
//    migrations.add(migration: migrateTableModel.self, database: .psql)
//    migrations.add(migration: migrateUserModel.self, database: .psql)
    
    services.register(migrations)
    
    
    // Mail Core
    
    let mailApi = Environment.get(EnvironmentKey.Mailgun.apiKey) ?? "7cfbf54808c1fcdc1df85e493ee8eaae-49a2671e-6bcf6a28"
    let mailDomain = Environment.get(EnvironmentKey.Mailgun.domain) ?? "sandboxf47ddf5df5a84e80bb4de8c2e7255c15.mailgun.org"
    
    let mailConfig = Mailer.Config.mailgun(key: mailApi, domain: mailDomain)
    try Mailer.init(config: mailConfig, registerOn: &services)
        
    // Reset Password
    
    try services.register(ResetProvider<User>(config: .current))
    
    services.register { _ -> LeafTagConfig in
        var tags = LeafTagConfig.default()
        tags.useResetLeafTags()
        return tags
    }
}

extension AppConfig {
    static var current: AppConfig {
        return AppConfig(
            name: env(EnvironmentKey.Project.name, "Servus Api"),
            url: env(EnvironmentKey.Project.url, "http://localhost:8080"),
            resetPasswordEmail: .init(
                fromEmail: "no-reply@like.st",
                subject: "Reset Password"
            ),
            setPasswordEmail: .init(
                fromEmail: "no-reply@like.st",
                subject: "Set Password"
            ),
            newUserRequestEmail: .init(
                fromEmail: "no-reply@like.st",
                toEmail: "test+user@nodes.dk",
                subject: "New User Request"
            ),
            newAppUserSetPasswordSigner: ExpireableJWTSigner(
                expirationPeriod: 30.daysInSecs,
                signer: .hs256(
                    key: env(
                        EnvironmentKey.Reset.setPasswordSignerKey, "secret-reset"
                        ).convertToData()
                )
            )
        )
    }
}

extension ResetConfig where U == User {
    static var current: ResetConfig<User> {
        return ResetConfig(
            name: AppConfig.current.name,
            baseURL: AppConfig.current.url,
            endpoints: .apiPrefixed,
            signer: .hs256(key: env(EnvironmentKey.Reset.signerKey, "secret-reset-appuser")
                .convertToData()),
            responses: .current
        )
    }
}

extension ResetResponses {
    public static var current: ResetResponses {
        return .init(
            resetPasswordRequestForm: { req in
                try HTTPResponse(status: .notFound).encode(for: req)
        },
            resetPasswordUserNotified: { req in
                try HTTPResponse(status: .noContent).encode(for: req)
        },
            resetPasswordForm: { req, user in
                try req
                    .make(LeafRenderer.self)
                    .render(ViewPath.Reset.form)
                    .encode(for: req)
        },
            resetPasswordSuccess: { req, user in
                try req
                    .make(LeafRenderer.self)
                    .render(ViewPath.Reset.success)
                    .encode(for: req)
        }
        )
    }
}
