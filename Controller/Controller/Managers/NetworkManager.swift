//
//  NetworkManager.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    private var baseURL: String = ""
    private var accessToken: String = ""
    private let session = URLSession.shared
    
    @Published var isConnected: Bool = false
    @Published var connectionStatus: String = "Не подключено"
    
    func configure(hubURL: String, accessToken: String) {
        self.baseURL = hubURL.trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessToken = accessToken
    }
    
    func testConnection() async -> Bool {
        guard !baseURL.isEmpty else {
            await MainActor.run {
                self.connectionStatus = "URL не может быть пустым"
            }
            return false
        }
        
        let urlString = baseURL.hasSuffix("/") ? baseURL + "api/ping" : baseURL + "/api/ping"
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                self.connectionStatus = "Некорректный формат URL"
            }
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0
        
        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                let success = httpResponse.statusCode == 200
                await MainActor.run {
                    self.isConnected = success
                    if success {
                        self.connectionStatus = "Подключено к \(baseURL)"
                    } else {
                        self.connectionStatus = "Ошибка подключения: HTTP \(httpResponse.statusCode)"
                    }
                }
                return success
            }
        } catch {
            await MainActor.run {
                self.isConnected = false
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        self.connectionStatus = "Нет подключения к интернету"
                    case .timedOut:
                        self.connectionStatus = "Превышено время ожидания. Проверьте URL и доступность сервера"
                    case .cannotFindHost:
                        self.connectionStatus = "Сервер не найден. Проверьте правильность URL"
                    case .cannotConnectToHost:
                        self.connectionStatus = "Не удалось подключиться к серверу"
                    default:
                        self.connectionStatus = "Ошибка подключения: \(error.localizedDescription)"
                    }
                } else {
                    self.connectionStatus = "Ошибка подключения: \(error.localizedDescription)"
                }
            }
        }
        return false
    }
    
    func sendInputEvent(_ event: InputEvent) async {
        guard isConnected, !baseURL.isEmpty else { return }
        
        let urlString = baseURL.hasSuffix("/") ? baseURL + "api/input" : baseURL + "/api/input"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(event)
            
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Input event sent: \(httpResponse.statusCode)")
            }
        } catch {
            print("Error sending input event: \(error.localizedDescription)")
        }
    }
    
    func sendOrientationEvent(_ event: OrientationEvent) async {
        guard isConnected, !baseURL.isEmpty else { return }
        
        let urlString = baseURL.hasSuffix("/") ? baseURL + "api/orientation" : baseURL + "/api/orientation"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(event)
            
            let (_, _) = try await session.data(for: request)
        } catch {
            print("Error sending orientation event: \(error.localizedDescription)")
        }
    }
}

