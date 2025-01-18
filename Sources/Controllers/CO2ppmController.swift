import Fluent
import Vapor

struct CO2ppmController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let co2ppmRoutes = routes.grouped("co2ppm")
        
        co2ppmRoutes.get(use: { try await self.index(req: $0) })
        co2ppmRoutes.post(use: { try await self.create(req: $0) })
        co2ppmRoutes.group(":co2ID") { co2PPMRoute in
            co2PPMRoute.delete(use: { try await self.delete(req: $0) })
        }
    }
    
    func index(req: Request) async throws -> [CO2ppmDTO] {
        try await CO2ppm.query(on: req.db).all().map { $0.toDTO() }
    }
    
    func create(req: Request) async throws -> CO2ppmDTO {
        let co2ppm = try req.content.decode(CO2ppmDTO.self).toModel()
        try await co2ppm.save(on: req.db)
        return co2ppm.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let co2ppm = try await CO2ppm.find(req.parameters.get("co2ppmID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await co2ppm.delete(on: req.db)
        return .noContent
    }
}
