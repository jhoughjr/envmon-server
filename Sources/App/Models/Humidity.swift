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
    
    @Field(key: "percentRH")
    var percentRH: Float
    
    @Field(key: "receivedAt")
    var receivedAt: Date
    
    init() { }
    
    init(id: UUID? = nil, percentRH: Float, receivedAt: Date) {
        self.id = id
        self.percentRH = percentRH
        self.receivedAt = receivedAt
    }
    
    func toDTO() -> HumidityDTO {
        .init(
            id: self.id,
            percentRH: self.percentRH,
            receivedAt: self.receivedAt
        )
    }
}
