import Foundation
import simd
import Combine
import DicyaninARKitSession
import RealityKit
import ARKit

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
        guard let handSkeleton = anchor.handSkeleton else {
            return Hand(thumbTip: nil, indexMCP: nil)
        }
        
        let originTransform = anchor.originFromAnchorTransform
        
        let thumbTipJoint = handSkeleton.joint(.thumbTip)
        let indexMCPJoint = handSkeleton.joint(.indexFingerTip)
        
        let thumbTipTransform = matrix_multiply(originTransform, thumbTipJoint.anchorFromJointTransform)
        let indexMCPTransform = matrix_multiply(originTransform, indexMCPJoint.anchorFromJointTransform)
        
        let thumbTipPos = SIMD3<Float>(thumbTipTransform.columns.3.x,
                                      thumbTipTransform.columns.3.y,
                                      thumbTipTransform.columns.3.z)
        let indexMCPPos = SIMD3<Float>(indexMCPTransform.columns.3.x,
                                      indexMCPTransform.columns.3.y,
                                      indexMCPTransform.columns.3.z)
        
        return Hand(thumbTip: thumbTipPos, indexMCP: indexMCPPos)
    }
}

public class ThumbController: ObservableObject {
    public static let shared = ThumbController(handSide: .right)
    
    @Published public private(set) var direction: SIMD3<Float> = .zero
    @Published public private(set) var magnitude: Float = 0.0
    @Published public private(set) var isActive: Bool = false
    
    private let handSide: HandSide
    private var cancellables = Set<AnyCancellable>()
    private let deadzone: Float
    private let maxDistance: Float
    private let scaleFactor: Float = 10.0  // Increased scale factor
    
    public init(handSide: HandSide, deadzone: Float = 0.02, maxDistance: Float = 0.15) {
        self.handSide = handSide
        self.deadzone = deadzone
        self.maxDistance = maxDistance
        
        setupHandTracking()
    }
    
    private func setupHandTracking() {
        ARKitSessionManager.shared.handTrackingUpdates
            .receive(on: DispatchQueue.main)
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
            print("DEBUG: No thumb tip position available")
            resetState()
            return
        }
        
        // Get the index finger MCP (knuckle) position as the center point
        guard let indexMCP = hand.indexMCP else {
            print("DEBUG: No index finger tip position available")
            resetState()
            return
        }
        
        // Calculate the vector from the center to the thumb tip
        let vector = thumbTip - indexMCP
        
        // Calculate the magnitude (distance)
        let distance = length(vector)
        
        // Check if we're within the deadzone
        if distance < deadzone {
            if isActive {
                print("DEBUG: Distance below deadzone (\(deadzone))")
                resetState()
            }
            return
        }
        
        // Normalize the vector and apply max distance
        let normalizedVector = normalize(vector)
        let clampedDistance = min(distance, maxDistance)
        let scaledVector = normalizedVector * clampedDistance
        
        // Apply significant scaling to make movement more pronounced
        let finalVector = scaledVector * scaleFactor
        
        // Update the state
        self.direction = finalVector
        self.magnitude = clampedDistance / self.maxDistance
        self.isActive = true
        
        print("DEBUG: Final direction: \(self.direction)")
        print("DEBUG: Final magnitude: \(self.magnitude)")
    }
    
    private func resetState() {
        print("DEBUG: Resetting state")
        self.direction = .zero
        self.magnitude = 0.0
        self.isActive = false
    }
    
    public func start() async throws {
        // Register the component and system
        ThumbControlledComponent.registerComponent()
        ThumbControlledSystem.registerSystem()
        
        try await ARKitSessionManager.shared.start()
    }
    
    public func stop() {
        ARKitSessionManager.shared.stop()
    }
} 
