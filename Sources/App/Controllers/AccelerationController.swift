import Fluent
import Vapor

struct AccelerationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let accelRoutes = routes.grouped("accel")
        
        accelRoutes.get(use: { try await self.index(req: $0) })
        accelRoutes.post(use: { try await self.create(req: $0) })
        accelRoutes.group(":accelID") { accelRoute in
            accelRoute.delete(use: { try await self.delete(req: $0) })
        }
    }
    
    func index(req: Request) async throws -> [AccelerationDTO] {
        try await Acceleration.query(on: req.db).all().map { $0.toDTO() }
    }
    
    func create(req: Request) async throws -> AccelerationDTO {
        let accel = try req.content.decode(AccelerationDTO.self).toModel()
        try await accel.save(on: req.db)
        return accel.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let accel = try await Acceleration.find(req.parameters.get("accelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await accel.delete(on: req.db)
        return .noContent
    }
}
