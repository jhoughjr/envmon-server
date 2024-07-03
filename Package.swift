// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "envmon-server",
    platforms: [
       .macOS(.v14)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.4"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        .package(
            url: "https://github.com/Zollerboy1/SwiftCommand.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/orlandos-nl/SSEKit.git",
            from: "1.0.1"
        )
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
//                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .product(name: "SSEKit", package: "SSEKit"),


            ],
            resources: [
                .copy("Public/")],
            swiftSettings: swiftSettings
            
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
