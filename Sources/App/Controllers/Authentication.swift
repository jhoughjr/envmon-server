//
//  Authentication.swift
//  
//
//  Created by Jimmy Hough Jr on 7/23/24.
//

import Vapor

import Vapor

struct UserNameAuthenticator: AsyncBasicAuthenticator {
    typealias User = App.User
    
    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
       // db lookup
    }
}

struct UserBearerAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User
    
    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
       // db lookup
    }
}

struct UserSessionAuthenticator: AsyncSessionAuthenticator {
    typealias User = App.User
    func authenticate(sessionID: String, for request: Request) async throws {
        // do lookup
    }
}


