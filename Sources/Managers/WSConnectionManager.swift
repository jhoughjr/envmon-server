//
//  WSConnectionManager.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

import Vapor
import NIOCore
import NIOExtras

final actor WSConnectionManager {
    
    typealias Connection = (Request, WebSocket)
    
    weak var application: Application?
    
    var logger: Logger?
    var connections = [Connection]()
    
    func configure(for app: Application) {
        self.application = app
        self.logger = app.logger
    }
    
    func connected(con: Connection) async {
        // cache the connection
        connections.append(con)
        con.0.logger.info("connections \(connections.count)")
        // add message handlers
        con.1.onText { ws, text in
            con.0.logger.info("ws sent text:\(text)")
        }
        
        con.1.onBinary { ws, bytes in
            con.0.logger.info("ws sent bytes:\(bytes.readableBytes) bytes")
        }
        
        //TODO: send last reading
        
//        if let v = application?.lastReadingManager?.lastReading {
//            let d = v.toJSON(date: application?.lastReadingManager?.timestamp)
//            let s = String(data:d, encoding: .utf8)
//            application?.logger.info("sending Last Reading")
//            application?.logger.info(("\(s!)"))
//            try await con.1.send(s!)
//        }
    }
    
    func disconnectAll() async throws {
        for con in connections {
            _ =  try await con.1.close(code: .normalClosure)
        }
    }
    
    func disconnect(con: Connection) async throws{
        _ =  try await con.1.close(code: .normalClosure)
    }
    
    func purgeDisconnectedClients() async {
        for con in connections {
            if con.1.isClosed {
                connections.removeAll { comp in
                    comp.0.id == con.0.id
                }
            }
        }
    }
    
    func broadcast(string: String) async throws {
        await purgeDisconnectedClients()
        for con in connections {
            try await con.1.send(string)
        }
    }
    
    func broadcast(bytes: ByteBuffer) async {
        await purgeDisconnectedClients()
        for con in connections {
            con.1.send(bytes)
        }
    }
}
