import Fluent
import Vapor
import SSEKit

func routes(_ app: Application) throws {

    // event stream
    let eventStream = AsyncStream<ServerSentEvent>.makeStream()

    try app.register(collection: TodoController())
    try app.register(collection: CO2ppmController())
    try app.register(collection: TemperatureController())
    try app.register(collection: HumidtyController())
    try app.register(collection: AccelerationController())

    app.post("envdata") { req async throws -> Response  in
        let env = try await EnvDTO.decodeRequest(req)
        let a = env.toModels()
        
        try await a.0.save(on: req.db) // temp
        try await a.1.save(on: req.db) // hum
        try await a.2.save(on: req.db) // ppm
        try await a.3.save(on: req.db) // acc
        let tevent = ServerSentEvent(type: "tmp", comment: nil, data: SSEValue(string: "\(a.0.degreesC)"), id: "\(a.0.id)")
        let hevent = ServerSentEvent(type: "hum", comment: nil, data: SSEValue(string: "\(a.1.percentRH)"), id: "\(a.1.id)")
        let cevent = ServerSentEvent(type: "co2", comment: nil, data: SSEValue(string: "\(a.2.co2ppm)"), id: "\(a.2.id)")
        eventStream.continuation.yield(tevent)
        eventStream.continuation.yield(hevent)
        eventStream.continuation.yield(cevent)

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
    
    app.on(.GET, "closeStream") { req -> Response in
        eventStream.continuation.finish()
        return .init(status: .accepted,
                     version: .http1_1,
                     headers: .init(),
                     body: .empty)
    }
    
    app.on(.GET, "sse", body: .stream) { req -> Response  in

        return Response(status: .ok,
                        version: .http1_1,
                        headers: .init([("content-type", "text/event-stream"),
                                        ("transfer-encoding", "chunked")]),
                        body: .init(asyncStream: { writer in
            
            req.logger.info("getting stuff in async body stream...")
            let stuff = eventStream.stream.mapToByteBuffer(allocator: app.allocator)
            do {
                for try await event in stuff {
                    req.logger.info("writting event in response for \(req.id)")
                    try await writer.writeBuffer(event)
                }
            }
            catch {
                req.logger.error("\(error)")
                req.logger.error("writting end")
                try await writer.write(.error(error))
            }
            
            // is this ever reached?
                req.logger.info("writting end fallthrough")
                try await writer.write(.end)
        }))
    }
}

