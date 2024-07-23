import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
        
    // DB - connection
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "envmon_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // DB - Migrations
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateTemperature())
    app.migrations.add(CreateHumidity())
    app.migrations.add(CreateCO2ppm())
    app.migrations.add(CreateAcceleration())
    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())

    
    // Middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // configure CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    app.views.use(.leaf)
    app.middleware.use(app.sessions.middleware)

    // Business Logic TODO - need to make these properly sendable
    app.wsConnections = WSConnectionManager(application:app)
    app.updateManager = UpdateIntervalManager()
    app.lastReadingManager = LastReadingManager()
    
    // register routes
    try routes(app)
}
