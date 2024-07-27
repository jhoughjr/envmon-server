//
//  EnvDTO.swift
//
//
//  Created by Jimmy Hough Jr on 5/10/24.
//
import Foundation
import Fluent
import Vapor

struct EnvDTO: Content {
    
    var id: UUID?
    var tempC: Float
    var hum: Float
    var ppm: Int
    var accel: AccelerationDTO
    var timestamp: Date?
    
    func toModels() -> (Date, Temperature, Humidity, CO2ppm, Acceleration) {
        let d = Date()
        
        let t = Temperature(degreesC: tempC, createdAt:  d)
        let h = Humidity(percentRH: hum, createdAt:  d)
        let c = CO2ppm(co2ppm: ppm, createdAt: d)
        let a = Acceleration(x: accel.x, y: accel.y, z: accel.z, createdAt: d)
        return (d,t,h,c,a)
    }
    
    func toJSON(date: Date?) -> Data {
        var c = ISO8601DateFormatter()
        var d:String? = nil
        
        if let arg = date {
            d = c.string(from: arg)
        }
        return
        """
        {
        \"timestamp" : \"\(d ?? "null")\",
        \"tempC\" : \(self.tempC),
        \"hum\" : \(self.hum),
        \"co2\" : \(self.ppm)
        }
        """.data(using: .utf8)!
        
    }
}
