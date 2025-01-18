import Fluent
import Vapor
import QueuesRedisDriver
import NIOCore

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
        
        if !WSConnectionManager.shared.connections.isEmpty {
            
            WSConnectionManager.shared.purgeDisconnectedClients()
            
            if let shit = String(data: data, encoding: .utf8) {
                WSConnectionManager.shared.broadcast(string: shit)
            }
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
       WSConnectionManager.shared.connected(con: (req,ws))
    }

}

