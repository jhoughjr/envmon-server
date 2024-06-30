//
//  HumidityDTO.swift
//  
//
//  Created by Jimmy Hough Jr on 5/9/24.
//

import Fluent
import Vapor

struct HumidityDTO: Content {
    var id: UUID?
    var percentRH: Float
    var createdAt: Date?
    
    func toModel() -> Humidity {
        let model = Humidity()
        
        model.id = self.id
        model.percentRH = self.percentRH
        model.createdAt = createdAt
        return model
    }
}
