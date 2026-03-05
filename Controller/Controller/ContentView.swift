//
//  ContentView.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack {
            if isConnected {
                ControllerView(networkManager: networkManager)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Disconnect") {
                                networkManager.isConnected = false
                                isConnected = false
                            }
                        }
                    }
            } else {
                ConnectionView(networkManager: networkManager, isConnected: $isConnected)
                    .onChange(of: isConnected) { oldValue, newValue in
                        networkManager.isConnected = newValue
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
