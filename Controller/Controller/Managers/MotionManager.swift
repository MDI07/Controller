//
//  MotionManager.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 0.1 // 100ms
    
    @Published var orientation: Orientation = Orientation(qx: 0, qy: 0, qz: 0, qw: 1.0)
    @Published var isActive: Bool = false
    
    var onOrientationUpdate: ((Orientation) -> Void)?
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateOrientation()
        }
        
        isActive = true
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        updateTimer?.invalidate()
        updateTimer = nil
        isActive = false
    }
    
    private func updateOrientation() {
        guard let motion = motionManager.deviceMotion else { return }
        
        let quaternion = motion.attitude.quaternion
        let newOrientation = Orientation(
            qx: quaternion.x,
            qy: quaternion.y,
            qz: quaternion.z,
            qw: quaternion.w
        )
        
        DispatchQueue.main.async {
            self.orientation = newOrientation
            self.onOrientationUpdate?(newOrientation)
        }
    }
    
    deinit {
        stopUpdates()
    }
}

