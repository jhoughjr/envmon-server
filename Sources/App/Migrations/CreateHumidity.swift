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
        try await database.schema("humidities")
            .id()
            .field("percentRH", .float, .required)
            .field("receivedAt", .date, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("humidities").delete()
    }
}
