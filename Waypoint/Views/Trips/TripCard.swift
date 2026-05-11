import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(trip.coverEmoji).font(.largeTitle)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.name).font(.headline)
                        Text("\(trip.startDate.shortDate) – \(trip.endDate.shortDate)")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    statusBadge
                }

                if !trip.cities.isEmpty {
                    Label(trip.cities.map(\.name).joined(separator: " · "), systemImage: "mappin")
                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }

                HStack(spacing: 16) {
                    Label("\(trip.totalDays)d", systemImage: "calendar")
                    Label("\(trip.cities.count)", systemImage: "building.2")
                    Label("\(trip.events.count)", systemImage: "list.bullet")
                }
                .font(.caption2).foregroundStyle(.tertiary)
            }
            .padding()
        }
        .background(Color.waypointCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
    }

    private var statusColor: Color {
        switch trip.status {
        case .upcoming: return .waypointAmber
        case .active:   return .green
        case .past:     return .gray
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch trip.status {
        case .upcoming:
            if let d = trip.daysUntilDeparture {
                badge(text: "in \(d)d", bg: .orange.opacity(0.2), fg: .orange)
            }
        case .active:
            if let n = trip.currentDayNumber {
                badge(text: "Day \(n)", bg: .green.opacity(0.2), fg: .green)
            }
        case .past:
            badge(text: "Past", bg: .gray.opacity(0.15), fg: .secondary)
        }
    }

    private func badge(text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(.caption).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(bg).foregroundStyle(fg)
            .clipShape(Capsule())
    }
}
