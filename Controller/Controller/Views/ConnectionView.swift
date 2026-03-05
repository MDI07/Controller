//
//  ConnectionView.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import SwiftUI

struct ConnectionView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var hubURL: String = ""
    @State private var accessToken: String = ""
    @State private var isConnecting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @Binding var isConnected: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Controller Setup")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hub URL")
                        .font(.headline)
                    TextField("https://example.com:8777", text: $hubURL)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .textContentType(.URL)
                    Text("Введите URL вашего сервера (например: https://192.168.1.100:8777)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Access Token")
                        .font(.headline)
                    SecureField("Enter access token", text: $accessToken)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .textContentType(.password)
                    Text("Введите токен доступа, выданный AdaOS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            
            Button(action: connect) {
                HStack {
                    if isConnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(isConnecting ? "Connecting..." : "Connect")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isConnecting ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isConnecting || hubURL.isEmpty || accessToken.isEmpty)
            .padding(.horizontal, 32)
            
            if networkManager.isConnected {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(networkManager.connectionStatus)
                            .foregroundColor(.green)
                    }
                    Text("Нажмите 'Disconnect' для отключения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if !networkManager.connectionStatus.isEmpty && networkManager.connectionStatus != "Not connected" {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Ошибка подключения")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    Text(networkManager.connectionStatus)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            
            Spacer()
            
            // Кнопка для очистки сохраненных настроек
            if !hubURL.isEmpty || !accessToken.isEmpty {
                Button(action: {
                    hubURL = ""
                    accessToken = ""
                    ConnectionSettings(hubURL: "", accessToken: "").save()
                }) {
                    Text("Очистить настройки")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        let settings = ConnectionSettings.load()
        hubURL = settings.hubURL
        accessToken = settings.accessToken
    }
    
    private func connect() {
        guard !hubURL.isEmpty, !accessToken.isEmpty else { return }
        
        // Валидация URL
        let trimmedURL = hubURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedURL.hasPrefix("http://") || trimmedURL.hasPrefix("https://") else {
            networkManager.connectionStatus = "Ошибка: URL должен начинаться с http:// или https://"
            return
        }
        
        isConnecting = true
        networkManager.configure(hubURL: trimmedURL, accessToken: accessToken)
        
        Task {
            let success = await networkManager.testConnection()
            await MainActor.run {
                isConnecting = false
                isConnected = success
                
                if success {
                    var settings = ConnectionSettings(hubURL: trimmedURL, accessToken: accessToken)
                    settings.save()
                }
            }
        }
    }
}

#Preview {
    ConnectionView(networkManager: NetworkManager(), isConnected: .constant(false))
}

