import Foundation
import simd
import Combine
import DicyaninARKitSession
import RealityKit

public enum HandSide {
    case left
    case right
}

public struct Hand {
    public let thumbTip: SIMD3<Float>?
    public let indexMCP: SIMD3<Float>?
    
    public init(thumbTip: SIMD3<Float>?, indexMCP: SIMD3<Float>?) {
        self.thumbTip = thumbTip
        self.indexMCP = indexMCP
    }
}

struct HandAnchorConverter {
    static func convert(_ anchor: HandAnchor) -> Hand {
        let thumbTip = anchor.handSkeleton?.joint(.thumbTip)?.position
        let indexMCP = anchor.handSkeleton?.joint(.indexFingerMCP)?.position
        
        return Hand(thumbTip: thumbTip, indexMCP: indexMCP)
    }
}

public class ThumbController: ObservableObject {
    @Published public private(set) var direction: SIMD3<Float> = .zero
    @Published public private(set) var magnitude: Float = 0.0
    @Published public private(set) var isActive: Bool = false
    
    private let handSide: HandSide
    private var cancellables = Set<AnyCancellable>()
    private let deadzone: Float
    private let maxDistance: Float
    
    public init(handSide: HandSide, deadzone: Float = 0.1, maxDistance: Float = 0.1) {
        self.handSide = handSide
        self.deadzone = deadzone
        self.maxDistance = maxDistance
        
        setupHandTracking()
    }
    
    private func setupHandTracking() {
        ARKitSessionManager.shared.handTrackingUpdates
            .sink { [weak self] update in
                guard let self = self else { return }
                
                let anchor = self.handSide == .left ? update.left : update.right
                
                if let anchor = anchor {
                    let hand = HandAnchorConverter.convert(anchor)
                    self.processHandPosition(hand)
                } else {
                    self.resetState()
                }
            }
            .store(in: &cancellables)
    }
    
    private func processHandPosition(_ hand: Hand) {
        // Get the thumb tip position
        guard let thumbTip = hand.thumbTip else {
            resetState()
            return
        }
        
        // Get the index finger MCP (knuckle) position as the center point
        guard let indexMCP = hand.indexMCP else {
            resetState()
            return
        }
        
        // Calculate the vector from the center to the thumb tip
        let vector = thumbTip - indexMCP
        
        // Calculate the magnitude (distance)
        let distance = length(vector)
        
        // Check if we're within the deadzone
        if distance < deadzone {
            resetState()
            return
        }
        
        // Normalize the vector and apply max distance
        let normalizedVector = normalize(vector)
        let clampedDistance = min(distance, maxDistance)
        let scaledVector = normalizedVector * clampedDistance
        
        // Update the state
        DispatchQueue.main.async {
            self.direction = scaledVector
            self.magnitude = clampedDistance / self.maxDistance
            self.isActive = true
        }
    }
    
    private func resetState() {
        DispatchQueue.main.async {
            self.direction = .zero
            self.magnitude = 0.0
            self.isActive = false
        }
    }
    
    public func start() async throws {
        try await ARKitSessionManager.shared.start()
    }
    
    public func stop() {
        ARKitSessionManager.shared.stop()
    }
} 
