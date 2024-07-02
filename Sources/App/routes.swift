import Fluent
import Vapor
import SSEKit

func routes(_ app: Application) throws {

    let eventStream = AsyncStream<ServerSentEvent>.makeStream()

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
    
    app.on(.GET, "makeevent") { req -> Response in
        let now = SSEValue(string: Date.now.ISO8601Format())
        let event = ServerSentEvent(data: now)
        
        let _ = eventStream.continuation.yield(event)
        return .init(status: .ok,
                     version: .http1_1,
                     headers: .init(),
                     body: .empty)
    }
    
    app.on(.GET, "sse", body: .stream) { request -> Response  in
        
        let now = SSEValue(string: Date.now.ISO8601Format())
        let event = ServerSentEvent(data: now)
        
        let _ = eventStream.continuation.yield(event)
                
        return Response(status: .ok,
                        version: .http1_1,
                        headers: .init([("content-type", "text/event-stream"),
                                        ("tranfer-encoding", "chunked")]),
                        body: .init(asyncStream: { writer in
            
            let stuff = eventStream.stream.mapToByteBuffer(allocator: app.allocator)
            
            for try await event in stuff {
                try await writer.writeBuffer(event)
            }
            try await writer.write(.end)
        }))
        
        
    }
}

