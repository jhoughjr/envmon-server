
import Fluent

struct CreateAcceleration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Acceleration.schema)
            .id()
            .field("x", .float, .required)
            .field("y", .float, .required)
            .field("z", .float, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Acceleration.schema).delete()
    }
}
