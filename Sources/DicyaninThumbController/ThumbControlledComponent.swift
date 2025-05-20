import RealityKit
import simd

public struct ThumbControlledComponent: Component {
    public var movementSpeed: Float
    
    public init(movementSpeed: Float = 1.0) {
        self.movementSpeed = movementSpeed
    }
}

public class ThumbControlledSystem: System {
    // Define a query to return all entities with ThumbControlledComponent
    private static let query = EntityQuery(where: .has(ThumbControlledComponent.self))
    
    // Required initializer
    public required init(scene: Scene) { }
    
    // Update method
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard let component = entity.components[ThumbControlledComponent.self] else { continue }
            
            // Apply movement if active
            if ThumbController.shared.isActive {
                let direction = ThumbController.shared.direction
                let magnitude = ThumbController.shared.magnitude
                
                // Calculate movement
                let baseMovement = direction * magnitude * component.movementSpeed * Float(context.deltaTime) * 2
                
                // Convert the direction into a joystick-like movement vector
                // Forward/backward movement (Z axis)
                let forwardMovement = baseMovement.z
                
                // Left/right movement (X axis)
                let horizontalMovement = baseMovement.x
                
                // Up/down movement (Y axis)
                let verticalMovement = baseMovement.y
                
                // Create the final movement vector
                let movement = SIMD3<Float>(
                    horizontalMovement,  // Left/right
                    verticalMovement,    // Up/down
                    forwardMovement      // Forward/backward
                )
                
                // Apply movement to entity
                entity.position += movement
            }
        }
    }
}

// Extension to make it easier to add the component to entities
public extension Entity {
    func addThumbControl(movementSpeed: Float = 1.0) {
        ThumbControlledComponent.registerComponent()
        ThumbControlledSystem.registerSystem()
        self.components[ThumbControlledComponent.self] = ThumbControlledComponent(movementSpeed: movementSpeed)
    }
    
    func removeThumbControl() {
        self.components[ThumbControlledComponent.self] = nil
    }
} 
