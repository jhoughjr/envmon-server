//
//  Temperature.swift
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
final class Temperature: Model, @unchecked Sendable {
    static let schema = "temperatures"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "degrees_c")
    var degreesC: Float
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, degreesC: Float, createdAt: Date) {
        self.id = id
        self.degreesC = degreesC
        self.createdAt = createdAt
    }
    
    func toDTO() -> TemperatureDTO {
        .init(
            id: self.id,
            degreesC: self.degreesC,
            createdAt: self.createdAt
        )
    }
}
