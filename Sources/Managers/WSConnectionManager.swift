//
//  WSConnectionManager.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

import Vapor
import NIOCore
import NIOExtras

final class WSConnectionManager {
    
    typealias Connection = (Request, WebSocket)
    nonisolated(unsafe) static let shared: WSConnectionManager = .init()
    
//    init(application:Application) {
//        self.application = application
//    }
//    let box = NIOLoopBoundBox.init([Connection](),
//                                   eventLoo
    
    
//    weak var application: Application?
    var connections = [Connection]()
    
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
        
//        if let v = application?.lastReadingManager?.lastReading {
//            let d = v.toJSON(date: application?.lastReadingManager?.timestamp)
//            let s = String(data:d, encoding: .utf8)
//            application?.logger.info("sending Last Reading")
//            application?.logger.info(("\(s!)"))
//            try await con.1.send(s!)
//        }
    }
    
    func disconnectAll()  {
        for con in connections {
            _ =  con.1.close(code: .normalClosure)
        }
    }
    
    func disconnect(con: Connection) {
        _ =  con.1.close(code: .normalClosure)
    }
    
    func purgeDisconnectedClients() {
        for con in connections {
            if con.1.isClosed {
                connections.removeAll { comp in
                    comp.0.id == con.0.id
                }
            }
        }
    }
    
    func broadcast(string: String) {
        purgeDisconnectedClients()
        for con in connections {
            con.1.send(string)
        }
    }
    
    func broadcast(bytes: ByteBuffer) {
        purgeDisconnectedClients()
        for con in connections {
            con.1.send(bytes)
        }
    }
}
