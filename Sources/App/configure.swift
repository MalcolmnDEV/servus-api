import Vapor
import Leaf
import Authentication
import FluentPostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    //    try services.register(FluentSQLiteProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
//        if env == .production {
//            let serverConfiure = NIOServerConfig.default(hostname: "0.0.0.0", port: 3000)
//            services.register(serverConfiure)
//        }
    
//    func configDBDev() -> PostgreSQLDatabaseConfig{
//        return PostgreSQLDatabaseConfig(hostname: "localhost",
//                                        port: 5432,
//                                        username: "malcolmnroberts",
//                                        database: "servus_dev",
//                                        password: nil)
//    }
//
//    func configDBProduction() -> PostgreSQLDatabaseConfig{
//
//        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "horton.elephantsql.com"
//        let port: Int
//        if let testPort = Environment.get("DATABASE_PORT") {
//            port = Int(testPort) ?? 5432
//        } else {
//            port = 5432
//        }
//
//        let username = Environment.get("DATABASE_USER") ?? "vwtdhmll"
//        let db = Environment.get("DATABASE_DB") ?? "vwtdhmll"
//        let pw = Environment.get("DATABASE_PASSWORD") ?? "uEtMFj_lHHuwILxa9Hie-ExriohcKlUb"
//
//        return PostgreSQLDatabaseConfig(hostname: hostname,
//                                        port: port,
//                                        username: username,
//                                        database: db,
//                                        password: pw)
//    }
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let port: Int
    if let testPort = Environment.get("DATABASE_PORT") {
        port = Int(testPort) ?? 5432
    } else {
        port = 5432
    }
    
    let username = Environment.get("DATABASE_USER") ?? "malcolmnroberts"
    let db = Environment.get("DATABASE_DB") ?? "servus_dev"
    let pw = Environment.get("DATABASE_PASSWORD") ?? nil
    
    let database = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: hostname,
                                                                       port: port,
                                                                       username: username,
                                                                       database: db,
                                                                       password: pw))
    
    
    // Configure a PostgreSQL database
    
//    let database = PostgreSQLDatabase(config: env == .production ? configDBProduction() : configDBDev())
    
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
    
    
    //Migrations
    migrations.add(migration: migrateOrganisationModel.self, database: .psql)
    migrations.add(migration: migrateTableModel.self, database: .psql)
    
    services.register(migrations)
    
}
