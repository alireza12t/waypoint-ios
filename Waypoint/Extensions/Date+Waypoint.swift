import Foundation

extension Date {
    var dayLabel: String {
        formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    var timeLabel: String {
        formatted(.dateTime.hour().minute())
    }

    var shortDate: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }

    var monthYear: String {
        formatted(.dateTime.month(.abbreviated).year())
    }
}
