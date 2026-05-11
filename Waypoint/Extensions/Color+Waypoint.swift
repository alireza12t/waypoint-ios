import SwiftUI

extension Color {
    static let waypointNavy   = Color(red: 0.04, green: 0.09, blue: 0.16)
    static let waypointAmber  = Color(red: 0.831, green: 0.569, blue: 0.102)
    static let waypointCard   = Color(UIColor.secondarySystemGroupedBackground)
    static let waypointBg     = Color(UIColor.systemGroupedBackground)
}

extension SpendCategory {
    var color: Color {
        switch self {
        case .food:          return .orange
        case .transport:     return .teal
        case .accommodation: return Color(red: 0.4, green: 0.3, blue: 0.9)
        case .activities:    return .red
        case .shopping:      return .pink
        case .other:         return .gray
        }
    }
}
