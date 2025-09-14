//
//  ShakeConfiguration.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import Foundation
import SwiftUI

enum ShakeSensitivity: String, CaseIterable, Codable {
    case verySensitive = "very_sensitive"
    case sensitive = "sentitive"
    case normal = "normal"
    case lessSensitive = "less_sensitive"
    
    var title: String {
        switch self {
        case .verySensitive:
            return "Muy sensible"
        case .sensitive:
            return "Sensible"
        case .normal:
            return "Normal"
        case .lessSensitive:
            return "Poco sensible"
        }
    }
    
    var description: String {
        switch self {
        case .verySensitive:
            return "Detecta movimientos muy leves"
        case .sensitive:
            return "Detecta movimientos leves"
        case .normal:
            return "Detecta movimientos moderados"
        case .lessSensitive:
            return "Detecta solo movimientos fuertes"
        }
    }
    
    var color: Color {
        switch self {
        case .verySensitive:
            return .red
        case .sensitive:
            return .orange
        case .normal:
            return .yellow
        case .lessSensitive:
            return .green
        }
    }
    
    var threshold: Double {
        switch self {
        case .verySensitive:
            return 0.5
        case .sensitive:
            return 1.0
        case .normal:
            return 1.5
        case .lessSensitive:
            return 2.0
        }
    }
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let sensitivity: ShakeSensitivity
    
    init(latitude: Double, longitude: Double, sensitivity: ShakeSensitivity) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date()
        self.sensitivity = sensitivity
    }
}
