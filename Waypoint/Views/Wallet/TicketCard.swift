import SwiftUI

struct TicketCard: View {
    let event: TripEvent

    var body: some View {
        VStack(spacing: 0) {
            // Colored header strip
            HStack {
                Image(systemName: event.type.icon).font(.body).foregroundStyle(.white)
                Text(event.type.displayName.uppercased())
                    .font(.caption).fontWeight(.bold).foregroundStyle(.white.opacity(0.9))
                Spacer()
                if event.confirmationNumber != nil {
                    Image(systemName: "qrcode").foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(event.type.color)

            // Body
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title).font(.headline).lineLimit(1)
                    Text("\(event.startTime.dayLabel) · \(event.startTime.timeLabel)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    if let conf = event.confirmationNumber {
                        Text("Ref: \(conf)").font(.caption).foregroundStyle(.tertiary).lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color.waypointCard)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
    }
}
