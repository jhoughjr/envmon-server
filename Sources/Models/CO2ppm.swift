//
//  CO2ppm.swift
//
//
//  Created by Jimmy Hough Jr on 5/9/24.
//

import Foundation
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class CO2ppm: Model, @unchecked Sendable {
    static let schema = "co2_ppms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "co2_ppm")
    var co2ppm: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, co2ppm: Int, createdAt: Date) {
        self.id = id
        self.co2ppm = co2ppm
        self.createdAt = createdAt
    }
    
    func toDTO() -> CO2ppmDTO {
        .init(
            id: self.id,
            co2ppm: self.co2ppm,
            createdAt: self.createdAt
        )
    }
}
