import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let attachment: Attachment
    @Environment(\.dismiss) var dismiss
    @State private var showQR = false

    var body: some View {
        NavigationStack {
            Group {
                if let url = attachment.bundledURL {
                    PDFRepresentable(url: url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.fill").font(.system(size: 64)).foregroundStyle(.secondary)
                        Text("Document not available").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(attachment.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                if attachment.hasQR {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            showQR = true
                        } label: {
                            Image(systemName: "qrcode")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showQR) {
            if let qr = attachment.qrCodeContent {
                QRDisplayView(content: qr, title: attachment.displayName)
            }
        }
    }
}

private struct PDFRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemGroupedBackground
        if let doc = PDFDocument(url: url) { pdfView.document = doc }
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {}
}
