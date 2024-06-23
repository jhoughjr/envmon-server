import Fluent
import Vapor

struct TemperatureController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tempRoutes = routes.grouped("temperature")
        
        tempRoutes.get(use: { try await self.index(req: $0) })
        tempRoutes.post(use: { try await self.create(req: $0) })
        tempRoutes.group(":tempID") { tempRoute in
            tempRoute.delete(use: { try await self.delete(req: $0) })
        }
    }
    
    func index(req: Request) async throws -> [TemperatureDTO] {
        try await Temperature.query(on: req.db).all().map { $0.toDTO() }
    }
    
    func create(req: Request) async throws -> TemperatureDTO {
        let temp = try req.content.decode(TemperatureDTO.self).toModel()
        try await temp.save(on: req.db)
        return temp.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let temp = try await Temperature.find(req.parameters.get("tempID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await temp.delete(on: req.db)
        return .noContent
    }
}

