//
//  EnvDTO.swift
//
//
//  Created by Jimmy Hough Jr on 5/10/24.
//

import Fluent
import Vapor

struct EnvDTO: Content {
    
    var id: UUID?
    var tempC: Float
    var hum: Float
    var ppm: Int
    
    func toModels() -> (Temperature, Humidity, CO2ppm) {
        let t = Temperature(degreesC: tempC, receivedAt: Date())
        let h = Humidity(percentRH: hum, receivedAt: Date())
        let c = CO2ppm(co2ppm: ppm, receivedAt: Date())
        
        return (t,h,c)
    }
}
