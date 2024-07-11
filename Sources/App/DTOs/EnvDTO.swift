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
    var accel: AccelerationDTO
    
    func toModels() -> (Temperature, Humidity, CO2ppm, Acceleration) {
        let d = Date()
        
        let t = Temperature(degreesC: tempC, createdAt:  d)
        let h = Humidity(percentRH: hum, createdAt:  d)
        let c = CO2ppm(co2ppm: ppm, createdAt: d)
        let a = Acceleration(x: accel.x, y: accel.y, z: accel.z, createdAt: d)
        return (t,h,c,a)
    }
    
    func toJSON() -> Data {
        """
        {
        \"tempC\" : \(self.tempC),
        \"hum\" : \(self.hum),
        \"co2\" : \(self.ppm)
        }
        """.data(using: .utf8)!
        
    }
}
