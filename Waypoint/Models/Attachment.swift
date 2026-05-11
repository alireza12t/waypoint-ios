import Foundation

enum AttachmentKind: String, Codable, CaseIterable {
    case ticket, document, receipt, photo

    var icon: String {
        switch self {
        case .ticket:   return "ticket.fill"
        case .document: return "doc.fill"
        case .receipt:  return "receipt"
        case .photo:    return "photo.fill"
        }
    }
}

struct Attachment: Identifiable, Codable {
    var id: UUID = UUID()
    var kind: AttachmentKind
    var displayName: String
    var filename: String
    var mimeType: String
    var qrCodeContent: String?
    var bundledResourceName: String?  // name (no extension) inside Bundle.main
    var parsedFields: [String: String] = [:]

    var bundledURL: URL? {
        guard let name = bundledResourceName else { return nil }
        let ext = mimeType == "application/pdf" ? "pdf" : "png"
        return Bundle.main.url(forResource: name, withExtension: ext)
    }

    var hasPDF: Bool { mimeType == "application/pdf" && bundledURL != nil }
    var hasQR: Bool  { qrCodeContent != nil }
}
