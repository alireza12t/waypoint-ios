import Foundation

enum AttachmentKind: String, Codable, CaseIterable {
    case ticket, document, receipt, photo
}

struct Attachment: Identifiable, Codable {
    var id: UUID = UUID()
    var kind: AttachmentKind
    var filename: String
    var mimeType: String
    var qrCodeContent: String?
    var parsedFields: [String: String] = [:]
}
