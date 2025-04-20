import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: "localhost",
        port: SQLPostgresConfiguration.ianaPortNumber,
        username: "envmon_user",
        password: "envmon_password",
        database: "envmon_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateTemperature())
    app.migrations.add(CreateHumidity())
    app.migrations.add(CreateCO2ppm())
    app.migrations.add(CreateAcceleration())

    app.views.use(.leaf)
    
    app.wsMan = WSConnectionManager()
    await app.wsMan?.configure(for: app)

    // register routes
    try routes(app)
}
