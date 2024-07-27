////
////  Authentication.swift
////  
////
////  Created by Jimmy Hough Jr on 7/23/24.
////
//
//import Vapor
//
//struct UserNameAuthenticator: AsyncBasicAuthenticator {
//    typealias User = App.User
//    
//    func authenticate(
//        basic: BasicAuthorization,
//        for request: Request
//    ) async throws {
//        if basic.username == "test" && basic.password == "secret" {
//            request.auth.login(User(name: "Vapor"))
//        }
//    }
//}
//
//struct UserBearerAuthenticator: AsyncBearerAuthenticator {
//    typealias User = App.User
//    
//    func authenticate(
//        bearer: BearerAuthorization,
//        for request: Request
//    ) async throws {
//        if bearer.token == "foo" {
//            request.auth.login(User(name: "Vapor"))
//        }
//    }
//}
