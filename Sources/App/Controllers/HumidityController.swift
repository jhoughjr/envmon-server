import Fluent
import Vapor

struct HumidtyController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let humiditieRoutes = routes.grouped("humidty")
        
        humiditieRoutes.get(use: { try await self.index(req: $0) })
        humiditieRoutes.post(use: { try await self.create(req: $0) })
        humiditieRoutes.group(":humID") { humRoute in
            humRoute.delete(use: { try await self.delete(req: $0) })
        }
    }
    
    func index(req: Request) async throws -> [HumidityDTO] {
        try await Humidity.query(on: req.db).all().map { $0.toDTO() }
    }
    
    func create(req: Request) async throws -> HumidityDTO {
        let hum = try req.content.decode(HumidityDTO.self).toModel()
        try await hum.save(on: req.db)
        return hum.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let hum = try await Humidity.find(req.parameters.get("humID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await hum.delete(on: req.db)
        return .noContent
    }
}
