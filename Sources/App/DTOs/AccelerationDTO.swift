//
//  File.swift
//  
//
//  Created by Jimmy Hough Jr on 6/24/24.
//

import Fluent
import Vapor

struct AccelerationDTO: Content {
    var id: UUID?
    var x: Float
    var y: Float
    var z: Float
    var createdAt: Date?
    
        
    func toModel() -> Acceleration {
        let model = Acceleration(x: x, y: y, z: z, createdAt: createdAt)
        return model
    }
}
