import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import Rainbow

final class ColorLogger: @unchecked Sendable, Middleware {
    public let logLevel: Logger.Level
    
    public init(logLevel: Logger.Level = .info) {
        self.logLevel = logLevel
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if let r = request.remoteAddress {
            let s = "\(r)".yellow.bold
            let m = Logger.Message(stringLiteral: "\(s) " + "\(request.method) ".green + "\(request.url.path.removingPercentEncoding ?? request.url.path)".lightBlue.bold +
                                   " [\(request.id)]".yellow)
            
            request.logger = Logger(label: "Colorized")
            request.logger.log(level: self.logLevel, m, metadata: .none)
        }
        return next.respond(to: request)
    }
}

// configures your application
public func configure(_ app: Application) async throws {
        
    // DB - connection
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "envmon_database",
        tls: .prefer(try .init(configuration: .clientDefault))) ),
                      as: .psql)

    // DB - Migrations
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateTemperature())
    app.migrations.add(CreateHumidity())
    app.migrations.add(CreateCO2ppm())
    app.migrations.add(CreateAcceleration())
    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())
    
    var mids = Middlewares.init()
    mids.use(
        FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // configure CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    mids.use(cors, at: .beginning)
    // Sessions
    mids.use(app.sessions.middleware)
    mids.use(ColorLogger(), at: .beginning)
    
    app.middleware = mids

    app.views.use(.leaf)

    // Business Logic TODO - need to make these properly sendable
    app.wsConnections = WSConnectionManager(application:app)
    app.updateManager = UpdateIntervalManager()
    app.lastReadingManager = LastReadingManager()
    
    // register routes
    try routes(app)
}
