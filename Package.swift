// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "servus-api",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        //        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/yonaskolb/Codability.git", from: "0.2.0-rc"),
        .package(url: "https://github.com/LiveUI/MailCore.git", .branch("master")),
        .package(url: "https://github.com/nodes-vapor/reset.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "3.0.0"),
        .package(url: "https://github.com/nodes-vapor/jwt-keychain.git", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication",
                                            "Leaf" ,
                                            "Vapor", 
                                            "FluentPostgreSQL", 
                                            "Codability", 
                                            "MailCore", 
                                            "Reset", 
                                            "Sugar",
                                            "JWTKeychain"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                    ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

