//
//  LastReadingManager.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

//
import Vapor

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
