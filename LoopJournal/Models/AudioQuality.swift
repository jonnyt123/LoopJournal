import Foundation

enum AudioQuality: String, CaseIterable, Identifiable {
    case standard
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .high: return "High"
        }
    }
}
