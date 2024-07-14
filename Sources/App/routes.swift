import Fluent
import Vapor

struct DateQueryDTO:Content {
    let start: Date
    let end: Date?
}

struct wsConManKey: StorageKey {
    typealias Value = WSConnectionManager
}

struct updaterKey: StorageKey {
    typealias Value = UpdateIntervalManager
}

struct lasytReadingKey: StorageKey {
    typealias Value = LastReadingManager
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

final class WSConnectionManager: Sendable {
    
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
        
        
        if let v = application.lastReadingManager?.lastReading {
                let d = v.toJSON()
                con.1.send(d)
        }

    }
    
    func disconnectAll() {
        for con in connections {
            _ = con.1.close(code: .normalClosure)
        }
    }
    
    func disconnect(con: Connection) {
        _ = con.1.close(code: .normalClosure)
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

final class UpdateIntervalManager: Sendable {
    
    var updateInterval:Int = 30_000
    
}

extension Application {
    var updateManager: UpdateIntervalManager? {
        get {
            self.storage[updaterKey.self]
        }
        set {
            self.storage[updaterKey.self] = newValue
        }
    }
}

final class LastReadingManager: Sendable {
    var lastReading:EnvDTO? = nil
    
}

extension Application {
    var lastReadingManager: LastReadingManager? {
        get {
            self.storage[lasytReadingKey.self]
        }
        set {
            self.storage[lasytReadingKey.self] = newValue
        }
    }
}

struct UpdateIntervalDTO: Content {
    let ms: Int
}


func routes(_ app: Application) throws {
    
    try app.register(collection: TodoController())
    try app.register(collection: CO2ppmController())
    try app.register(collection: TemperatureController())
    try app.register(collection: HumidtyController())
    try app.register(collection: AccelerationController())
    
    app.post("updateInterval") {  req async throws -> Response  in
        let i = try req.content.decode(UpdateIntervalDTO.self)
        app.updateManager?.updateInterval = i.ms
        
        return .init(status: .ok)
    }
    
    // need to update hw to dl this and consume it
    app.get("updateInterval") {  req async throws -> Response  in
        let v = app.updateManager?.updateInterval ?? 30_000
        return try await UpdateIntervalDTO(ms: v).encodeResponse(for: req)
    }
    
    app.get("lastReading") { req async throws -> Response in
       return try await app.lastReadingManager?.lastReading?.encodeResponse(for: req)  ??
              .init(status: .noContent)
    }
    
    // ui
    app.get("") { req async throws -> View in
        
        return try await req.view.render("index", ["socketaddr" : "ws://localhost:8080/envrt",
                                                   "hostname": "localhost:8080"])
    }
    
    // realtime
    app.post("envdata") { req async throws -> Response  in
        // decode
        let env = try await EnvDTO.decodeRequest(req)
        let a = env.toModels()
        
        // store
        try await a.0.save(on: req.db) // temp
        try await a.1.save(on: req.db) // hum
        try await a.2.save(on: req.db) // ppm
        try await a.3.save(on: req.db) // acc
        
        req.logger.info("notifying webscoket \(app.wsConnections?.connections.count ?? 0) clients")
        // i dont like this
        // should return models not env maybe?
        let data = env.toJSON()
        app.lastReadingManager?.lastReading = env
        app.wsConnections?.purgeDisconnectedClients()
        try await app.wsConnections?.broadcast(string: String(data: data, encoding: .utf8)!)
        req.logger.info("accepting")
        return Response(status: .accepted)
    }
    
    app.get("envdata","temps") { req async throws -> Response in
        
        if let range = try? req.query.decode(DateQueryDTO.self) {
            
            req.logger.info("\(range)")
            
            let temps = try await Temperature.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .all()
            
            let coded = try JSONEncoder().encode(temps)
            
            return .init(status: .ok,
                         body: .init(data: coded))
        }else {
            let temps = try await Temperature.query(on: req.db)
                .all()
            
            let coded = try JSONEncoder().encode(temps)
            
            return .init(status: .ok,
                         body: .init(data: coded))
        }
    }
                     
    app.get("envdata","hums") { req async throws -> Response in
        if let range = try? req.query.decode(DateQueryDTO.self) {
            req.logger.info("\(range)")
            
            let hums = try await Humidity.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .all()
            
            let coded = try JSONEncoder().encode(hums)
            return .init(status: .ok,
                         body: .init(data: coded))
        }else {
            let hums = try await Humidity.query(on: req.db)
                .all()
            
            let coded = try JSONEncoder().encode(hums)
            return .init(status: .ok,
                         body: .init(data: coded))
        }
    }
    
    app.get("envdata","co2s") { req async throws -> Response in
        
        if let range = try? req.query.decode(DateQueryDTO.self) {
            req.logger.info("\(range)")
            
            let co2s = try await CO2ppm.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .all()
            
            let coded = try JSONEncoder().encode(co2s)
            return .init(status: .ok,
                         body: .init(data: coded))
        }else {
            let co2s = try await CO2ppm.query(on: req.db)
                .all()
            let coded = try JSONEncoder().encode(co2s)
            return .init(status: .ok,
                         body: .init(data: coded))
        }
    }
    
    // realtime
    app.webSocket("envrt") { req, ws in
        app.wsConnections?.connected(con: (req,ws))
        req.logger.info("Connected ws for \(req.remoteAddress?.ipAddress ?? "unknown")")
    }
}

