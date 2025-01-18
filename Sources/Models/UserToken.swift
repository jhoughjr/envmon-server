////
////  UserToken.swift
////  
////
////  Created by Jimmy Hough Jr on 7/23/24.
////
//import Fluent
//import Vapor
//
//final class UserToken: Model, @unchecked Sendable, Content {
//    static let schema = "user_tokens"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Field(key: "value")
//    var value: String
//    
//    @Parent(key: "user_id")
//    var user: User
//    
//    init() { }
//    
//    init(id: UUID? = nil, value: String, userID: User.IDValue) {
//        self.id = id
//        self.value = value
//        self.$user.id = userID
//    }
//}
//
//extension UserToken {
//    struct Migration: AsyncMigration {
//        var name: String { "CreateUserToken" }
//        
//        func prepare(on database: Database) async throws {
//            try await database.schema("user_tokens")
//                .id()
//                .field("value", .string, .required)
//                .field("user_id", .uuid, .required, .references("users", "id"))
//                .unique(on: "value")
//                .create()
//        }
//        
//        func revert(on database: Database) async throws {
//            try await database.schema("user_tokens").delete()
//        }
//    }
//}
//
//extension UserToken: ModelTokenAuthenticatable {
//    
//    
//    
//    
//    static var valueKey: KeyPath<UserToken, Field<String>> {
//        \UserToken.$value
//    }
//    
//    static let userKey = \UserToken.$user
//    
//    var isValid: Bool {
//        true // check exp date
//    }
//}
