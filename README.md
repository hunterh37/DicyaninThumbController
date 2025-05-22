# DicyaninThumbController

A Swift package for visionOS that provides thumb-based joystick control using hand tracking. This package uses the DicyaninHandSessionManager to track hand positions and converts thumb movements into a virtual joystick input.

![DicyaninThumbControllerGif4](https://github.com/user-attachments/assets/d0d9fef3-cdb1-4b9b-9209-c8b4ceefa032)



## Features

- Left or right hand support
- Configurable deadzone and maximum distance
- Real-time SIMD3 direction vector output
- Magnitude control for variable input strength
- Active state tracking
- RealityKit ECS component for easy entity control

## Requirements

- visionOS 1.0+
- Swift 5.9+
- [DicyaninARKitSession package](https://github.com/hunterh37/DicyaninARKitSession)

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/hunterh37/DicyaninThumbController.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import DicyaninThumbController

// Create a thumb controller for the right hand
let thumbController = ThumbController(handSide: .right)

// Start the controller
try await thumbController.start()

// Observe the direction and magnitude
thumbController.$direction
    .sink { direction in
        // Use the direction vector (SIMD3<Float>)
        print("Direction: \(direction)")
    }
    .store(in: &cancellables)

thumbController.$magnitude
    .sink { magnitude in
        // Use the magnitude (0.0 to 1.0)
        print("Magnitude: \(magnitude)")
    }
    .store(in: &cancellables)

// Check if the controller is active
thumbController.$isActive
    .sink { isActive in
        print("Controller active: \(isActive)")
    }
    .store(in: &cancellables)

// Stop the controller when done
thumbController.stop()
```

### Using with RealityKit ECS

```swift
import DicyaninThumbController
import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        RealityView { content in
            // Start the shared thumb controller
            Task {
                try? await ThumbController.shared.start()
            }
            
            // Create an entity to control
            let entity = ModelEntity(mesh: .generateBox(size: 0.1))
            entity.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
            
            // Add thumb control to the entity with a movement speed of 2.0
            entity.addThumbControl(movementSpeed: 2.0)
            
            // Add the entity to the scene
            content.add(entity)
        }
    }
}
```

The ECS integration provides automatic movement control for entities. The `ThumbControlledComponent` will:
- Track the thumb position relative to the index finger
- Convert thumb movements into entity movement
- Apply movement speed scaling
- Handle deadzone and maximum distance constraints

You can adjust the movement speed when adding the component:
```swift
// Slower movement
entity.addThumbControl(movementSpeed: 1.0)

// Faster movement
entity.addThumbControl(movementSpeed: 3.0)
```

To remove thumb control from an entity:
```swift
entity.removeThumbControl()
```

## Configuration

The `ThumbController` can be configured with the following parameters:

- `handSide`: Choose between `.left` or `.right` hand
- `deadzone`: Minimum distance before the controller becomes active (default: 0.02)
- `maxDistance`: Maximum distance for full magnitude (default: 0.15)

Example with custom configuration:

```swift
let thumbController = ThumbController(
    handSide: .left,
    deadzone: 0.05,
    maxDistance: 0.15
)
```

## How It Works

The controller uses the thumb tip position relative to the index finger tip to create a virtual joystick. The direction is calculated as a normalized vector, and the magnitude is scaled based on the distance between these points.

- The thumb tip position is used as the joystick position
- The index finger tip is used as the center point
- The vector between these points determines the direction and magnitude
- A deadzone prevents small movements from triggering the controller
- The maximum distance parameter limits how far the thumb can move for full magnitude

## License

This package is licensed under the MIT License. See the LICENSE file for details. 
