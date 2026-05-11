import SwiftUI

struct EventCard: View {
    let event: TripEvent
    let tripID: UUID

    var body: some View {
        HStack(spacing: 12) {
            // Time column
            VStack(alignment: .trailing, spacing: 2) {
                Text(event.startTime.timeLabel)
                    .font(.caption).fontWeight(.medium).monospacedDigit()
                if let end = event.endTime {
                    Text(end.timeLabel)
                        .font(.caption2).foregroundStyle(.tertiary).monospacedDigit()
                }
            }
            .frame(width: 54, alignment: .trailing)

            // Icon circle
            ZStack {
                Circle().fill(event.type.color.opacity(0.18)).frame(width: 36, height: 36)
                Image(systemName: event.type.icon).font(.system(size: 14)).foregroundStyle(event.type.color)
            }

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(event.title)
                        .font(.subheadline).fontWeight(.medium)
                        .strikethrough(event.isDone)
                        .foregroundStyle(event.isDone ? .secondary : .primary)
                    Spacer(minLength: 4)
                    if !event.warningNotes.isEmpty {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    if event.isDone {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                    }
                }
                if let loc = event.locationName {
                    Text(loc).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                if let dur = event.durationText {
                    Text(dur).font(.caption2).foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
