# DicyaninThumbController

A Swift package for visionOS that provides thumb-based joystick control using hand tracking. This package uses the DicyaninHandSessionManager to track hand positions and converts thumb movements into a virtual joystick input.

## Features

- Left or right hand support
- Configurable deadzone and maximum distance
- Real-time SIMD3 direction vector output
- Magnitude control for variable input strength
- Active state tracking

## Requirements

- visionOS 1.0+
- Swift 5.9+
- DicyaninHandSessionManager package

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/hunterh37/DicyaninThumbController.git", from: "1.0.0")
]
```

## Usage

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

## Configuration

The `ThumbController` can be configured with the following parameters:

- `handSide`: Choose between `.left` or `.right` hand
- `deadzone`: Minimum distance before the controller becomes active (default: 0.1)
- `maxDistance`: Maximum distance for full magnitude (default: 0.1)

Example with custom configuration:

```swift
let thumbController = ThumbController(
    handSide: .left,
    deadzone: 0.05,
    maxDistance: 0.15
)
```

## How It Works

The controller uses the thumb tip position relative to the index finger knuckle (MCP) to create a virtual joystick. The direction is calculated as a normalized vector, and the magnitude is scaled based on the distance between these points.

- The thumb tip position is used as the joystick position
- The index finger MCP (knuckle) is used as the center point
- The vector between these points determines the direction and magnitude
- A deadzone prevents small movements from triggering the controller
- The maximum distance parameter limits how far the thumb can move for full magnitude

## License

This package is licensed under the MIT License. See the LICENSE file for details. 