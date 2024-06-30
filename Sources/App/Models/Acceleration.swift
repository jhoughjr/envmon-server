
import Foundation
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Acceleration: Model, @unchecked Sendable {
    static let schema = "accelerations"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "x")
    var x: Float
    
    @Field(key: "y")
    var y: Float
    
    @Field(key: "z")
    var z: Float
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    
    init() { }
    
    init(id: UUID? = nil, x: Float, y: Float, z: Float, createdAt: Date?) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.createdAt = createdAt
    }
    
    func toDTO() -> AccelerationDTO {
        .init(
            id: self.id,
            x: self.x,
            y: self.y,
            z: self.z,
            createdAt: self.createdAt
        )
    }
}
