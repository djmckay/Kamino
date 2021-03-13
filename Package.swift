// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Kamino",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on MySQL 3.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        // 🔏 JSON Web Token signing and verification (HMAC, RSA).
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        //.package(url: "https://github.com/IBM-Swift/Swift-SMTP", .upToNextMinor(from: "5.1.0")),   
    ],
    targets: [
        .target(name: "App", dependencies: [
                    .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
                    .product(name: "Vapor", package: "vapor")],
                SwiftSetting: [.unsafeFlags(["-cross-module-optimization"]
                                                .when(configuration: .release))
                ]),
//                    "FluentMySQL", "Vapor", "Leaf", "Authentication", "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

