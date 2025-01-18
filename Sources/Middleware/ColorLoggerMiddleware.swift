//
//  ColorLoggerMiddleware.swift
//  
//
//  Created by Jimmy Hough Jr on 8/1/24.
//
import Vapor
import Rainbow

final class ColorLogger: @unchecked Sendable, Middleware {
    public let logLevel: Logger.Level
    
    public init(logLevel: Logger.Level = .info) {
        self.logLevel = logLevel
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if let r = request.remoteAddress {
            let s = "\(r)".yellow.bold
            let m = Logger.Message(stringLiteral: "\(s) " + "\(request.method) ".green + "\(request.url.path.removingPercentEncoding ?? request.url.path)".lightBlue.bold +
                                   " [\(request.id)]".yellow)
            
            request.logger = Logger(label: "Colorized")
            request.logger.log(level: self.logLevel, m, metadata: .none)
        }
        return next.respond(to: request)
    }
}

