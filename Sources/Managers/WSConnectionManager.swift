//
//  WSConnectionManager.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

import Vapor

actor WSConnectionManager  {
    
    typealias Connection = (Request, WebSocket)
    
    init(application:Application) {
        self.application = application
    }
    
    var connections = [Connection]()
    
    weak var application: Application?
    
    func connected(con: Connection) async throws {
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
        
        if let v = application?.lastReadingManager?.lastReading {
            let d = v.toJSON(date: application?.lastReadingManager?.timestamp)
            let s = String(data:d, encoding: .utf8)
            application?.logger.info("sending Last Reading")
            application?.logger.info(("\(s!)"))
            try await con.1.send(s!)
        }
    }
    
    func disconnectAll() async throws {
        for con in connections {
            _ = try await con.1.close(code: .normalClosure)
        }
    }
    
    func disconnect(con: Connection) async throws {
        _ = try await con.1.close(code: .normalClosure)
    }
    
    func purgeDisconnectedClients() async {
        for con in connections {
            if con.1.isClosed {
                application?.logger.info("purging \(con.0.id)")
                connections.removeAll { comp in
                    comp.0.id == con.0.id
                }
            }
        }
    }
    
    func broadcast(string: String) async throws {
        await purgeDisconnectedClients()
        for con in connections {
            application?.logger.info("sending to \(con.0.id)")
            try await con.1.send(string)
        }
    }
    
    func broadcast(bytes: ByteBuffer) async throws {
        await purgeDisconnectedClients()
        for con in connections {
            con.1.send(bytes)
        }
    }
}

extension Application {
    
    var wsManager: WSConnectionManager? {
        get {
            self.storage[wsConManKey.self]
        }
        set {
            self.storage[wsConManKey.self] = newValue
        }
    }
}

