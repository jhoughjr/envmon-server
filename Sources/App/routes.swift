import Fluent
import Vapor

struct wsConManKey: StorageKey {
    typealias Value = WSConnectionManager
}

extension Application {
    var wsConnections: WSConnectionManager? {
        get {
            self.storage[wsConManKey.self]
        }
        set {
            self.storage[wsConManKey.self] = newValue
        }
    }
}

final class WSConnectionManager {
    
    typealias Connection = (Request, WebSocket)
    init(application:Application) {
        self.application = application
    }
    
    var connections = [Connection]()
    var application: Application
    
    func connected(con: Connection) {
        // cache the connection
        connections.append(con)
        
        // add message handlers
        con.1.onText { ws, text in
            con.0.logger.info("\(text)")
        }
        
        con.1.onBinary { ws, bytes in
            con.0.logger.info("\(bytes.readableBytes) bytes")
        }

    }
    
    func disconnectAll() {
        for con in connections {
            con.1.close(code: .normalClosure)
        }
    }
    
    func disconnect(con: Connection) {
        con.1.close(code: .normalClosure)
    }
    
    func purgeDisconnectedClients() {
        for con in connections {
            if con.1.isClosed {
                application.logger.info("purging \(con.0.id)")
                connections.removeAll { comp in
                    comp.0.id == con.0.id
                }
            }
        }
    }
    
    func broadcast(string: String) async throws {
        purgeDisconnectedClients()
        for con in connections {
            application.logger.info("sending to \(con.0.id)")
            try await con.1.send(string)
        }
    }
    
    func broadcast(bytes: ByteBuffer) async throws {
        purgeDisconnectedClients()
        for con in connections {
            con.1.send(bytes)
        }
    }
}


func routes(_ app: Application) throws {
    
    try app.register(collection: TodoController())
    try app.register(collection: CO2ppmController())
    try app.register(collection: TemperatureController())
    try app.register(collection: HumidtyController())
    try app.register(collection: AccelerationController())

    app.post("envdata") { req async throws -> Response  in
        // decode
        req.logger.info("decoding...")
        let env = try await EnvDTO.decodeRequest(req)
        req.logger.info("converting to models...")
        let a = env.toModels()
        
        req.logger.info("saving to db")
        // store
        try await a.0.save(on: req.db) // temp
        try await a.1.save(on: req.db) // hum
        try await a.2.save(on: req.db) // ppm
        try await a.3.save(on: req.db) // acc
        
        req.logger.info("notifying webscoket \(app.wsConnections?.connections.count ?? 0) clients")
        // i dont like this
        // need to find another way to hook into this event without making the rsponse depend on the broadcast
        let data = env.toJSON()
        
        req.logger.info("broadcasting...")
        app.wsConnections?.purgeDisconnectedClients()
        try await app.wsConnections?.broadcast(string: String(data: data, encoding: .utf8)!)
        req.logger.info("accepting")
        return Response(status: .accepted)
    }
    
    app.webSocket("envrt") { req, ws in
        app.wsConnections?.connected(con: (req,ws))
        req.logger.info("Connected ws for \(req.remoteAddress?.ipAddress ?? "unknown")")
    }
    
}

