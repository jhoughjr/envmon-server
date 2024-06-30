import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.get { req async in
//        "envmon-server is OK."
//    }
    
    try app.register(collection: TodoController())
    try app.register(collection: CO2ppmController())
    try app.register(collection: TemperatureController())
    try app.register(collection: HumidtyController())
    
    app.post("envdata") { req async throws -> Response  in
        let env = try await EnvDTO.decodeRequest(req)
        let a = env.toModels()
        
        try await a.0.save(on: req.db) // temp
        try await a.1.save(on: req.db) // hum
        try await a.2.save(on: req.db) // ppm
        try await a.3.save(on: req.db) // acc
        
        return Response(status: .accepted)
    }
    
}
