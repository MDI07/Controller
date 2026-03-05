//
//  GameButton.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import SwiftUI

struct GameButton: View {
    let label: String
    @Binding var isPressed: Bool
    let onPress: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isPressed ? Color.green : Color.blue)
                .frame(width: 80, height: 80)
                .shadow(radius: isPressed ? 2 : 5)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
            
            Text(label)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onPress()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onRelease()
                }
        )
    }
}

#Preview {
    GameButton(
        label: "A",
        isPressed: .constant(false),
        onPress: {},
        onRelease: {}
    )
}

