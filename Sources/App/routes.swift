import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "envmon-server is OK."
    }
    try app.register(collection: TodoController())
    try app.register(collection: CO2ppmController())
    try app.register(collection: TemperatureController())
    try app.register(collection: HumidtyController())
    
    app.post("envdata") { req async throws -> Response  in
        print("req \(req)")
        let env = try await EnvDTO.decodeRequest(req)
        print("\(env)")
        let a = env.toModels()
        
        try await a.0.save(on: req.db)
        try await a.1.save(on: req.db)
        try await a.2.save(on: req.db)
        
        return Response(status: .accepted)
    }
    
}
