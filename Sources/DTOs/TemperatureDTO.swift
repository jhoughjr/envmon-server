//
//  TemperatureDTO.swift
//  
//
//  Created by Jimmy Hough Jr on 5/9/24.
//

import Fluent
import Vapor

struct TemperatureDTO: Content {
    var id: UUID?
    var degreesC: Float
    var createdAt: Date?
    
    func toModel() -> Temperature {
        let model = Temperature()
        
        model.id = self.id
        model.degreesC = self.degreesC
        model.createdAt = self.createdAt
        return model
    }
}
