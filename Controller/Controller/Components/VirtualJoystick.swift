//
//  VirtualJoystick.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import SwiftUI

struct VirtualJoystick: View {
    @Binding var position: CGPoint
    let size: CGFloat
    let onChanged: (Double, Double) -> Void
    
    @State private var isDragging = false
    
    private var joystickRadius: CGFloat {
        size * 0.4
    }
    
    private var maxDistance: CGFloat {
        size * 0.35
    }
    
    var body: some View {
        ZStack {
            // Outer circle (background)
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
            
            // Inner circle (joystick handle)
            Circle()
                .fill(Color.blue)
                .frame(width: joystickRadius, height: joystickRadius)
                .offset(x: position.x, y: position.y)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let translation = value.translation
                            let distance = sqrt(pow(translation.width, 2) + pow(translation.height, 2))
                            
                            if distance <= maxDistance {
                                position = CGPoint(x: translation.width, y: translation.height)
                            } else {
                                let angle = atan2(translation.height, translation.width)
                                position = CGPoint(
                                    x: cos(angle) * maxDistance,
                                    y: sin(angle) * maxDistance
                                )
                            }
                            
                            let normalizedX = Double(position.x / maxDistance)
                            let normalizedY = Double(-position.y / maxDistance) // Invert Y for standard game coordinates
                            onChanged(normalizedX, normalizedY)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                position = .zero
                            }
                            isDragging = false
                            onChanged(0, 0)
                        }
                )
        }
    }
}

#Preview {
    VirtualJoystick(
        position: .constant(.zero),
        size: 150,
        onChanged: { x, y in
            print("Joystick: x=\(x), y=\(y)")
        }
    )
}

