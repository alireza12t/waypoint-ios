import SwiftUI

struct TicketCard: View {
    let event: TripEvent

    var body: some View {
        VStack(spacing: 0) {
            // Colored header strip
            HStack {
                Image(systemName: event.isDone ? "checkmark.circle.fill" : event.type.icon)
                    .font(.body).foregroundStyle(.white)
                Text(event.type.displayName.uppercased())
                    .font(.caption).fontWeight(.bold).foregroundStyle(.white.opacity(0.9))
                Spacer()
                if event.isDone {
                    Text("DONE").font(.caption2).fontWeight(.bold)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.white.opacity(0.25)).clipShape(Capsule())
                        .foregroundStyle(.white)
                } else if event.confirmationNumber != nil || !event.attachments.isEmpty {
                    Image(systemName: "qrcode").foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(event.isDone ? .gray : event.type.color)

            // Body
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title).font(.headline)
                        .strikethrough(event.isDone)
                        .foregroundStyle(event.isDone ? .secondary : .primary)
                    Text("\(event.startTime.dayLabel) · \(event.startTime.timeLabel)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    if let conf = event.confirmationNumber, conf.count <= 24 {
                        Text("Ref: \(conf)").font(.caption).foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color.waypointCard)
            .opacity(event.isDone ? 0.6 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(event.isDone ? 0.04 : 0.12), radius: 5, y: 2)
    }
}
