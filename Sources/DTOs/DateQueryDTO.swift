//
//  DateQueryDTO.swift
//  envmon-server
//
//  Created by Jimmy Hough Jr on 1/18/25.
//
import Vapor

struct DateQueryDTO: Content {
    let start: Date
    let end: Date?
}
