//
//  Humidity.swift
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
final class Humidity: Model, @unchecked Sendable {
    static let schema = "humidities"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "percent_rh")
    var percentRH: Float
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, percentRH: Float, createdAt: Date?) {
        self.id = id
        self.percentRH = percentRH
        self.createdAt = createdAt
    }
    
    func toDTO() -> HumidityDTO {
        .init(
            id: self.id,
            percentRH: self.percentRH,
            createdAt: self.createdAt
        )
    }
}
