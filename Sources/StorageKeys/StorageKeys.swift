//
//  StorageKeys.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//

import Vapor

struct LastReadingKey: StorageKey {
    typealias Value = LastReadingManager
}


struct UpdateKey: StorageKey {
    typealias Value = UpdateIntervalManager
}
