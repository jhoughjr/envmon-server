//
//  CO2ppmDTO.swift
//  
//
//  Created by Jimmy Hough Jr on 5/9/24.
//

import Fluent
import Vapor

struct CO2ppmDTO: Content {
    var id: UUID?
    var co2ppm: Int
    var receivedAt: Date
    
    func toModel() -> CO2ppm {
        let model = CO2ppm()
        
        model.id = self.id
        model.co2ppm = self.co2ppm
        model.receivedAt = receivedAt
        return model
    }
}
