import RealityKit
import simd

public struct ThumbControlledComponent: Component {
    public var movementSpeed: Float
    
    public init(movementSpeed: Float = 1.0) {
        self.movementSpeed = movementSpeed
    }
}

public struct ThumbControlledSystem: System {
    public static var dependencies: [SystemDependency] {
        [.init(componentType: ThumbControlledComponent.self)]
    }
    
    public func update(context: SceneUpdateContext) {
        // Get all entities with ThumbControlledComponent
        let query = EntityQuery(where: .has(ThumbControlledComponent.self))
        
        // Update each entity
        context.scene.performQuery(query).forEach { entity in
            guard let component = entity.components[ThumbControlledComponent.self] else { return }
            
            // Apply movement if active
            if ThumbController.shared.isActive {
                let direction = ThumbController.shared.direction
                let magnitude = ThumbController.shared.magnitude
                
                // Calculate movement
                let movement = direction * magnitude * component.movementSpeed * Float(context.deltaTime)
                
                // Apply movement to entity
                entity.position += movement
            }
        }
    }
}

// Extension to make it easier to add the component to entities
public extension Entity {
    func addThumbControl(movementSpeed: Float = 1.0) {
        self.components[ThumbControlledComponent.self] = ThumbControlledComponent(movementSpeed: movementSpeed)
    }
    
    func removeThumbControl() {
        self.components[ThumbControlledComponent.self] = nil
    }
} 