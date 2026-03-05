//
//  ControllerView.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import SwiftUI

struct ControllerView: View {
    @StateObject private var networkManager: NetworkManager
    @StateObject private var motionManager = MotionManager()
    
    @State private var joystickPosition = CGPoint.zero
    @State private var joystickX: Double = 0
    @State private var joystickY: Double = 0
    @State private var buttonAPressed = false
    @State private var buttonBPressed = false
    
    @State private var eventLog: [String] = []
    @State private var deviceId: String = ""
    
    init(networkManager: NetworkManager) {
        _networkManager = StateObject(wrappedValue: networkManager)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Status bar
                    HStack {
                        Circle()
                            .fill(networkManager.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(networkManager.isConnected ? "Connected" : "Disconnected")
                            .foregroundColor(.white)
                            .font(.caption)
                        Spacer()
                        if motionManager.isActive {
                            Image(systemName: "gyroscope")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Main controller area
                    HStack(spacing: 40) {
                        // Left side - Joystick
                        VStack {
                            Text("Joystick")
                                .foregroundColor(.white)
                                .font(.caption)
                            VirtualJoystick(
                                position: $joystickPosition,
                                size: 150,
                                onChanged: { x, y in
                                    joystickX = x
                                    joystickY = y
                                    sendInputEvent()
                                }
                            )
                        }
                        
                        Spacer()
                        
                        // Right side - Buttons
                        VStack(spacing: 30) {
                            GameButton(
                                label: "A",
                                isPressed: $buttonAPressed,
                                onPress: {
                                    sendInputEvent()
                                },
                                onRelease: {
                                    sendInputEvent()
                                }
                            )
                            
                            GameButton(
                                label: "B",
                                isPressed: $buttonBPressed,
                                onPress: {
                                    sendInputEvent()
                                },
                                onRelease: {
                                    sendInputEvent()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Event log
                    if !eventLog.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recent Events")
                                .foregroundColor(.white)
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(eventLog.prefix(5), id: \.self) { log in
                                        Text(log)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 10, design: .monospaced))
                                    }
                                }
                            }
                            .frame(height: 80)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            if networkManager.isConnected {
                motionManager.onOrientationUpdate = { orientation in
                    sendOrientationEvent(orientation)
                }
                motionManager.startUpdates()
            }
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
    }
    
    private func sendInputEvent() {
        let event = InputEvent(
            type: "mobile_input",
            deviceId: deviceId,
            axes: Axes(x: joystickX, y: joystickY),
            buttons: Buttons(A: buttonAPressed, B: buttonBPressed),
            ts: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        Task {
            await networkManager.sendInputEvent(event)
            await MainActor.run {
                let logEntry = String(format: "[%.3f, %.3f] A:%@ B:%@",
                                     joystickX, joystickY,
                                     buttonAPressed ? "1" : "0",
                                     buttonBPressed ? "1" : "0")
                eventLog.insert(logEntry, at: 0)
                if eventLog.count > 10 {
                    eventLog.removeLast()
                }
            }
        }
    }
    
    private func sendOrientationEvent(_ orientation: Orientation) {
        let event = OrientationEvent(
            type: "mobile_orientation",
            orientation: orientation
        )
        
        Task {
            await networkManager.sendOrientationEvent(event)
        }
    }
}

#Preview {
    ControllerView(networkManager: NetworkManager())
}

