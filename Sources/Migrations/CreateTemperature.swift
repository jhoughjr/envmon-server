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
        try await database.schema(Temperature.schema)
            .id()
            .field("degrees_c", .float, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Temperature.schema).delete()
    }
}
