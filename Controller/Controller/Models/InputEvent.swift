//
//  InputEvent.swift
//  Controller
//
//  Created by Daniel on 23.12.2025.
//

import Foundation

struct InputEvent: Codable {
    let type: String
    let deviceId: String
    let axes: Axes?
    let buttons: Buttons?
    let ts: Int64
    
    enum CodingKeys: String, CodingKey {
        case type
        case deviceId = "device_id"
        case axes
        case buttons
        case ts
    }
}

struct Axes: Codable {
    let x: Double
    let y: Double
}

struct Buttons: Codable {
    let A: Bool
    let B: Bool
}

struct OrientationEvent: Codable {
    let type: String
    let orientation: Orientation
}

struct Orientation: Codable {
    let qx: Double
    let qy: Double
    let qz: Double
    let qw: Double
}

