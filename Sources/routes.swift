import Fluent
import Vapor
import QueuesRedisDriver
import NIOCore

struct DateQueryDTO:Content {
    let start: Date
    let end: Date?
}

struct LastReadingKey: StorageKey {
    typealias Value = LastReadingManager
}

struct wsConManKey: StorageKey {
    typealias Value = WSConnectionManager
}

struct UpdateKey: StorageKey {
    typealias Value = UpdateIntervalManager
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

actor WSConnectionManager: Sendable {
    
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
        
        //TODO: send last reading
        
        if let v = application.lastReadingManager?.lastReading {
            let d = v.toJSON(date: application.lastReadingManager?.timestamp)
            let s = String(data:d, encoding: .utf8)
            application.logger.info("sending Last Reading")
            application.logger.info(("\(s!)"))
            con.1.send(s!)
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
    
    func broadcast(string: String) throws {
        purgeDisconnectedClients()
        for con in connections {
            application.logger.info("sending to \(con.0.id)")
            con.1.send(string)
        }
    }
    
    func broadcast(bytes: ByteBuffer) throws {
        purgeDisconnectedClients()
        for con in connections {
            con.1.send(bytes)
        }
    }
}

final class UpdateIntervalManager: @unchecked Sendable {
    
    var updateInterval:Int = 30_000
    
}

extension Application {
    var updateManager: UpdateIntervalManager? {
        get {
            self.storage[UpdateKey.self]
        }
        set {
            self.storage[UpdateKey.self] = newValue
        }
    }
}
//
final class LastReadingManager: @unchecked Sendable {
    var lastReading: EnvDTO? = nil
    var timestamp: Date? = nil
}

extension Application {
    var lastReadingManager: LastReadingManager? {
        get {
            self.storage[LastReadingKey.self]
        }
        set {
            self.storage[LastReadingKey.self] = newValue
        }
    }
}

struct UpdateIntervalDTO: Content {
    let ms: Int
}

func routes(_ app: Application) throws {
        
//     remote board control
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
    
    // ui
    app.get("") { req async throws -> View in
        
        let host = "jimmyhoughjr.freeddns.org"
        let port = app.http.server.configuration.port

        return try await req.view.render("index", ["socketaddr" : "ws://\(host):\(port)/envrt",
                                                   "hostname": "\(host):\(port)",
                                                   "protocol" :"http"])
    }
    
    // realtime input
    app.post("envdata") { req async throws -> Response  in
        // decode
        let d = Date()
        
        let env: EnvDTO = try await EnvDTO.decodeRequest(req)
        let a = env.toModels()
        
        // store
        try await a.1.save(on: req.db) // temp
        try await a.2.save(on: req.db) // hum
        try await a.3.save(on: req.db) // ppm
        try await a.4.save(on: req.db) // acc
        
        // i dont like this
        // should return models not env maybe?
        let data = env.toJSON(date: d)
        
        app.lastReadingManager?.lastReading = env
        app.lastReadingManager?.timestamp = d
        
        if await !app.wsConnections!.connections.isEmpty {
            await app.wsConnections!.purgeDisconnectedClients()
            try await app.wsConnections?.broadcast(string: String(data: data, encoding: .utf8)!)
        }

        return Response(status: .accepted)
    }
    
    app.post("register") { req async throws -> Response  in
        .init(status: .notImplemented)
    }
                  
    app.get("lastReading") { req async throws -> Response in
        if let last = app.lastReadingManager?.lastReading {
            req.logger.info("last = \(last)")
            return try await last.encodeResponse(for: req)
        }else {
            return .init(status: .noContent)
        }
    }
    
    // paginated
    /*
     GET /planets?page=2&per=5 HTTP/1.1
     The above request would yield a response structured like the following.
     
     {
     "items": [...],
     "metadata": {
     "page": 2,
     "per": 5,
     "total": 8
     }
     }
     */
    app.get("envdata","temps") { req async throws -> Response in
        
        if let range = try? req.query.decode(DateQueryDTO.self) {
            
            req.logger.info("\(range)")
            
            let temps = try await Temperature.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .paginate(for: req)
            
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
    
    app.get("envdata", "temps", "all") {  req async throws -> Response in
        
        let temps = try await Temperature.query(on: req.db)
                                         .all()
        
        let coded = try JSONEncoder().encode(temps)
        
        return .init(status: .ok,
                     body: .init(data: coded))
    }
    
    app.get("envdata","hums") { req async throws -> Response in
        if let range = try? req.query.decode(DateQueryDTO.self) {
            req.logger.info("\(range)")
            
            let hums = try await Humidity.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .paginate(for: req)
            
            let coded = try JSONEncoder().encode(hums)
            return .init(status: .ok,
                         body: .init(data: coded))
        }else {
            
            let hums = try await Humidity.query(on: req.db)
                                         .paginate(for: req)
            
            let coded = try JSONEncoder().encode(hums)
            return .init(status: .ok,
                         body: .init(data: coded))
        }
    }
    
    app.get("envdata", "hums","all") { req async throws -> Response in
        
        let hums = try await Humidity.query(on: req.db)
            .all()
        
        let coded = try JSONEncoder().encode(hums)
        return .init(status: .ok,
                     body: .init(data: coded))
    }
    
    app.get("envdata","co2s") { req async throws -> Response in
        
        if let range = try? req.query.decode(DateQueryDTO.self) {
            req.logger.info("\(range)")
            
            let co2s = try await CO2ppm.query(on: req.db)
                .filter(\.$createdAt >= range.start)
                .filter(\.$createdAt <= range.end ?? Date())
                .paginate(for: req)

            let coded = try JSONEncoder().encode(co2s)
            return .init(status: .ok,
                         body: .init(data: coded))
        }else {
            let co2s = try await CO2ppm.query(on: req.db)
                .paginate(for: req)

            let coded = try JSONEncoder().encode(co2s)
            return .init(status: .ok,
                         body: .init(data: coded))
        }
    }
    
    app.get("envdata","co2s","all") { req async throws -> Response in
        let co2s = try await CO2ppm.query(on: req.db)
                                   .all()
        let coded = try JSONEncoder().encode(co2s)
        return .init(status: .ok,
                     body: .init(data: coded))
    }
    
    // realtime output
    
    app.webSocket("envrt") { req, ws in
        Task {
            await app.wsConnections?.connected(con: (req,ws))
            req.logger.info("Connected ws for \(req.remoteAddress?.ipAddress ?? "unknown")")
        }
    }

}

