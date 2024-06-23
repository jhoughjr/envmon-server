//
//  CreateTemperature.swift
//  
//
//  Created by Jimmy Hough Jr on 5/10/24.
//

import Foundation
import Fluent

struct CreateTemperature: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("temperatures")
            .id()
            .field("degreesC", .float, .required)
            .field("receivedAt", .date, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("temperatures").delete()
    }
}
