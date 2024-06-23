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
    static let schema = "CO2ppms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "co2ppm")
    var co2ppm: Int
    
    @Field(key: "receivedAt")
    var receivedAt: Date
    
    init() { }
    
    init(id: UUID? = nil, co2ppm: Int, receivedAt: Date) {
        self.id = id
        self.co2ppm = co2ppm
        self.receivedAt = receivedAt
    }
    
    func toDTO() -> CO2ppmDTO {
        .init(
            id: self.id,
            co2ppm: self.co2ppm,
            receivedAt: self.receivedAt
        )
    }
}
