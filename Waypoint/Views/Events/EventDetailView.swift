import SwiftUI

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .top) {
            Text(label).font(.subheadline).foregroundStyle(.secondary).frame(width: 120, alignment: .leading)
            Text(value).font(.subheadline).fontWeight(.medium).multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Main View

struct EventDetailView: View {
    let event: TripEvent
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @Environment(\.dismiss) var dismiss
    @State private var showQR = false
    @State private var selectedAttachment: Attachment?
    @State private var notifEnabled: Bool = false
    @State private var notifOffset: NotificationOffset = .thirtyMin

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    typeSection.padding()
                    if !event.warningNotes.isEmpty { warningSection.padding(.horizontal).padding(.bottom) }
                    if !event.attachments.isEmpty  { attachmentsSection.padding(.horizontal).padding(.bottom) }
                    notificationsSection.padding(.horizontal).padding(.bottom)
                    if !event.notes.isEmpty        { notesSection.padding(.horizontal).padding(.bottom) }
                    actionButtons.padding()
                }
            }
            .navigationTitle(event.type.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .onAppear {
            notifEnabled = event.notificationEnabled
            notifOffset  = event.notificationOffset
        }
        .sheet(isPresented: $showQR) {
            if let conf = event.confirmationNumber {
                QRDisplayView(content: conf, title: event.title)
            }
        }
        .sheet(item: $selectedAttachment) { att in
            if att.hasPDF {
                PDFViewerView(attachment: att)
            } else if let qr = att.qrCodeContent {
                QRDisplayView(content: qr, title: att.displayName)
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(event.type.color.opacity(0.2)).frame(width: 56, height: 56)
                    Image(systemName: event.type.icon).font(.title2).foregroundStyle(event.type.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title).font(.title3).fontWeight(.bold)
                    Text("\(event.startTime.dayLabel) · \(event.startTime.timeLabel)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    if let dur = event.durationText {
                        Text(dur).font(.caption).foregroundStyle(.tertiary)
                    }
                }
                Spacer()
            }
            .padding()

            if event.type.isTransport,
               let dep = event.locationName ?? nil,
               !dep.isEmpty || event.arrivalLocationName != nil {
                routeStrip(departure: event.locationName, arrival: event.arrivalLocationName)
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
        .background(event.type.color.opacity(0.08))
    }

    private func routeStrip(departure: String?, arrival: String?) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FROM").font(.caption2).foregroundStyle(.secondary)
                Text(departure ?? "—").font(.subheadline).fontWeight(.semibold).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "arrow.right").foregroundStyle(event.type.color)

            VStack(alignment: .trailing, spacing: 2) {
                Text("TO").font(.caption2).foregroundStyle(.secondary)
                Text(arrival ?? "—").font(.subheadline).fontWeight(.semibold).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(12)
        .background(event.type.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: Type-specific

    @ViewBuilder
    private var typeSection: some View {
        switch event.payload {
        case .flight(let p):        FlightDetail(p: p, conf: event.confirmationNumber)
        case .train(let p):         TrainDetail(p: p, conf: event.confirmationNumber)
        case .bus(let p):           BusDetail(p: p, conf: event.confirmationNumber)
        case .accommodation(let p): AccomDetail(p: p, conf: event.confirmationNumber)
        case .attraction(let p):    AttrDetail(p: p, conf: event.confirmationNumber)
        case .none:
            if let conf = event.confirmationNumber { InfoRow(label: "Ref", value: conf) }
        }
    }

    // MARK: Warnings

    private var warningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Important", systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline).fontWeight(.semibold).foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(event.warningNotes, id: \.self) { note in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption).foregroundStyle(.orange).padding(.top, 2)
                        Text(note).font(.subheadline)
                    }
                }
            }
            .padding(12).background(Color.orange.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Documents & Tickets").font(.subheadline).fontWeight(.semibold).foregroundStyle(.secondary)
            ForEach(event.attachments) { att in
                Button { selectedAttachment = att } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color.waypointAmber.opacity(0.15)).frame(width: 40, height: 40)
                            Image(systemName: att.kind.icon).foregroundStyle(Color.waypointAmber)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(att.displayName).font(.subheadline).fontWeight(.medium)
                            HStack(spacing: 6) {
                                if att.hasQR {
                                    Label("QR", systemImage: "qrcode")
                                        .font(.caption2).foregroundStyle(.green)
                                }
                                if att.hasPDF {
                                    Label("PDF", systemImage: "doc.fill")
                                        .font(.caption2).foregroundStyle(.red)
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                    }
                    .padding(12).background(Color.waypointCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $notifEnabled.animation()) {
                Label("Remind me", systemImage: "bell.fill")
                    .font(.subheadline).fontWeight(.semibold)
            }
            .tint(Color.waypointAmber)
            .onChange(of: notifEnabled) { _ in saveNotifSettings() }

            if notifEnabled {
                Picker("When", selection: $notifOffset) {
                    ForEach(NotificationOffset.allCases, id: \.self) { offset in
                        Text(offset.rawValue).tag(offset)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: notifOffset) { _ in saveNotifSettings() }
            }
        }
        .padding(14)
        .background(Color.waypointCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func saveNotifSettings() {
        var updated = event
        updated.notificationEnabled = notifEnabled
        updated.notificationOffset  = notifOffset
        store.updateEvent(updated, in: tripID)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes").font(.subheadline).fontWeight(.semibold).foregroundStyle(.secondary)
            Text(event.notes).font(.body)
        }
    }

    // MARK: Actions

    private func mapsURL(lat: Double, lng: Double, name: String) -> URL? {
        let q = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "maps://?ll=\(lat),\(lng)&q=\(q)")
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if event.confirmationNumber != nil || !event.attachments.isEmpty {
                let hasPDF = event.attachments.contains(where: { $0.hasPDF })
                let hasQR  = event.attachments.contains(where: { $0.hasQR }) || event.confirmationNumber != nil
                Button {
                    if let att = event.attachments.first(where: { $0.hasPDF }) {
                        selectedAttachment = att
                    } else {
                        showQR = true
                    }
                } label: {
                    HStack {
                        Label("Show Ticket", systemImage: hasPDF ? "doc.fill" : "qrcode")
                        Spacer()
                        if hasQR { Image(systemName: "qrcode").font(.caption).foregroundStyle(.secondary) }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered).tint(event.type.color)
            }

            if let lat = event.latitude, let lng = event.longitude {
                let label = event.type.isTransport ? "Departure in Maps" : "Open in Maps"
                let name  = event.locationName ?? event.title
                if let url = mapsURL(lat: lat, lng: lng, name: name) {
                    Button { UIApplication.shared.open(url) } label: {
                        Label(label, systemImage: event.type.isTransport ? "arrow.up.right.circle" : "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }

            if event.type.isTransport, let lat = event.arrivalLatitude, let lng = event.arrivalLongitude {
                let name = event.arrivalLocationName ?? "Arrival"
                if let url = mapsURL(lat: lat, lng: lng, name: name) {
                    Button { UIApplication.shared.open(url) } label: {
                        Label("Arrival in Maps", systemImage: "arrow.down.right.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Button {
                store.toggleDone(event.id, in: tripID)
                dismiss()
            } label: {
                Label(event.isDone ? "Mark as Pending" : "Mark as Done",
                      systemImage: event.isDone ? "circle" : "checkmark.circle")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered).tint(event.isDone ? .secondary : .green)
        }
    }
}

// MARK: - Type Detail Sections

private struct FlightDetail: View {
    let p: FlightPayload; let conf: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                vstack(p.origin, "From")
                Spacer()
                Image(systemName: "airplane").font(.title2).foregroundStyle(.blue)
                Spacer()
                vstack(p.destination, "To")
            }
            .padding(12).background(Color.blue.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))

            if !p.flightNumber.isEmpty { InfoRow(label: "Flight",    value: "\(p.airline) \(p.flightNumber)") }
            if !p.pnr.isEmpty          { InfoRow(label: "PNR",       value: p.pnr) }
            if !p.seatNumber.isEmpty   { InfoRow(label: "Seat",      value: p.seatNumber) }
            if !p.cabinClass.isEmpty   { InfoRow(label: "Class",     value: p.cabinClass) }
            if !p.terminal.isEmpty     { InfoRow(label: "Terminal",  value: p.terminal) }
            if !p.gate.isEmpty         { InfoRow(label: "Gate",      value: p.gate) }
            if let c = conf            { InfoRow(label: "Booking Ref", value: c) }
        }
    }
    private func vstack(_ title: String, _ sub: String) -> some View {
        VStack { Text(title).font(.title2).fontWeight(.bold); Text(sub).font(.caption).foregroundStyle(.secondary) }
    }
}

private struct TrainDetail: View {
    let p: TrainPayload; let conf: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                vstack(p.origin, "From"); Spacer()
                Image(systemName: "tram.fill").foregroundStyle(.teal)
                Spacer(); vstack(p.destination, "To")
            }
            .padding(12).background(Color.teal.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
            if !p.operatorName.isEmpty { InfoRow(label: "Operator", value: p.operatorName) }
            if !p.trainNumber.isEmpty  { InfoRow(label: "Train",    value: p.trainNumber) }
            if !p.carriage.isEmpty     { InfoRow(label: "Carriage", value: p.carriage) }
            if !p.seat.isEmpty         { InfoRow(label: "Seat",     value: p.seat) }
            if let c = conf            { InfoRow(label: "Booking Ref", value: c) }
        }
    }
    private func vstack(_ t: String, _ s: String) -> some View {
        VStack { Text(t).font(.headline); Text(s).font(.caption).foregroundStyle(.secondary) }
    }
}

private struct BusDetail: View {
    let p: BusPayload; let conf: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if p.inPersonPurchase {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                    Text("Buy ticket in person at station").fontWeight(.semibold)
                }
                .padding(12).background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10)).foregroundStyle(.orange)
            }
            if !p.company.isEmpty     { InfoRow(label: "Company", value: p.company) }
            if !p.origin.isEmpty      { InfoRow(label: "From",    value: p.origin) }
            if !p.destination.isEmpty { InfoRow(label: "To",      value: p.destination) }
            if !p.seat.isEmpty        { InfoRow(label: "Seat",    value: p.seat) }
            if let c = conf           { InfoRow(label: "Booking Ref", value: c) }
        }
    }
}

private struct AccomDetail: View {
    let p: AccommodationPayload; let conf: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                vstack("Check-in",  p.checkInTime)
                Spacer()
                vstack("Check-out", p.checkOutTime)
            }
            .padding(12).background(Color(red:0.4,green:0.3,blue:0.9).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if !p.address.isEmpty      { InfoRow(label: "Address",       value: p.address) }
            if !p.phone.isEmpty        { InfoRow(label: "Phone",         value: p.phone) }
            if let c = conf            { InfoRow(label: "Confirmation",  value: c) }
            if !p.wifiName.isEmpty     { InfoRow(label: "WiFi",          value: p.wifiName) }
            if !p.wifiPassword.isEmpty { InfoRow(label: "WiFi Password", value: p.wifiPassword) }
            if !p.lockCode.isEmpty     { InfoRow(label: "Lock Code",     value: p.lockCode) }
        }
    }
    private func vstack(_ label: String, _ val: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(val).font(.title3).fontWeight(.semibold)
        }
    }
}

private struct AttrDetail: View {
    let p: AttractionPayload; let conf: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !p.meetingPoint.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill").foregroundStyle(.red)
                    Text("Meet at: \(p.meetingPoint)").font(.subheadline)
                }
                .padding(12).background(Color.red.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
            }
            if !p.provider.isEmpty      { InfoRow(label: "Provider",    value: p.provider) }
            if !p.providerPhone.isEmpty { InfoRow(label: "Phone",       value: p.providerPhone) }
            if let c = conf             { InfoRow(label: "Booking Ref", value: c) }
            if !p.pin.isEmpty           { InfoRow(label: "PIN",         value: p.pin) }
            if p.price > 0 {
                InfoRow(label: "Price", value: "\(p.priceCurrency) \(String(format: "%.2f", p.price))")
            }
        }
    }
}
