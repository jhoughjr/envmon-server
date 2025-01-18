//
//  CreateHumidity.swift
//
//
//  Created by Jimmy Hough Jr on 5/10/24.
//


import Foundation
import Fluent

struct CreateHumidity: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Humidity.schema)
            .id()
            .field("percent_rh", .float, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Humidity.schema).delete()
    }
}
