//
//  UpdateIntervalManager.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

import Vapor

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
