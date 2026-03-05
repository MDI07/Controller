//
//  ConnectionSettings.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import Foundation

struct ConnectionSettings: Codable {
    var hubURL: String
    var accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case hubURL = "hub_url"
        case accessToken = "access_token"
    }
    
    static let defaults = UserDefaults.standard
    
    static func load() -> ConnectionSettings {
        if let data = defaults.data(forKey: "connection_settings"),
           let settings = try? JSONDecoder().decode(ConnectionSettings.self, from: data) {
            return settings
        }
        return ConnectionSettings(hubURL: "", accessToken: "")
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            ConnectionSettings.defaults.set(data, forKey: "connection_settings")
        }
    }
}

