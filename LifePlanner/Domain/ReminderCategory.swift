import SwiftUI

enum ReminderCategory: String, CaseIterable, Codable, Identifiable {
    case girlfriend
    case classes
    case social
    case shpe
    case lul
    case groceries
    case gym

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .girlfriend:
            return "Girlfriend"
        case .classes:
            return "Classes"
        case .social:
            return "Social"
        case .shpe:
            return "SHPE"
        case .lul:
            return "LUL"
        case .groceries:
            return "Groceries"
        case .gym:
            return "Gym"
        }
    }

    var symbolName: String {
        switch self {
        case .girlfriend:
            return "heart.fill"
        case .classes:
            return "book.fill"
        case .social:
            return "person.3.fill"
        case .shpe:
            return "person.2.wave.2.fill"
        case .lul:
            return "sparkles"
        case .groceries:
            return "cart.fill"
        case .gym:
            return "figure.strengthtraining.traditional"
        }
    }

    var accentColor: Color {
        switch self {
        case .girlfriend:
            return .pink
        case .classes:
            return .blue
        case .social:
            return .orange
        case .shpe:
            return .red
        case .lul:
            return .purple
        case .groceries:
            return .green
        case .gym:
            return .mint
        }
    }
}
