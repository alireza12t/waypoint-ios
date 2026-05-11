import Foundation

enum SpendCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case accommodation = "Accommodation"
    case activities = "Activities"
    case shopping = "Shopping"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "tram.fill"
        case .accommodation: return "bed.double.fill"
        case .activities: return "ticket.fill"
        case .shopping: return "bag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct Receipt: Identifiable, Codable {
    var id: UUID = UUID()
    var merchant: String
    var amount: Double
    var date: Date
    var category: SpendCategory
    var cityID: UUID? = nil
    var notes: String = ""
}
