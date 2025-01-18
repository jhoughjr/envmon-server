//
//  CreateCO2ppm.swift
//
//
//  Created by Jimmy Hough Jr on 5/10/24.
//


import Fluent

struct CreateCO2ppm: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(CO2ppm.schema)
            .id()
            .field("co2_ppm", .int, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(CO2ppm.schema).delete()
    }
}
