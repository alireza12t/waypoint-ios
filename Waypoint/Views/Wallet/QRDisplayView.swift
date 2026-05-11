import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRDisplayView: View {
    let content: String
    let title: String
    @Environment(\.dismiss) var dismiss
    @State private var qrImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                VStack(spacing: 32) {
                    Text(title).font(.title3).fontWeight(.semibold).foregroundStyle(.black)
                        .multilineTextAlignment(.center).padding(.horizontal)

                    if let img = qrImage {
                        Image(uiImage: img)
                            .interpolation(.none).resizable().scaledToFit()
                            .frame(maxWidth: 280)
                            .padding(20).background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 8)
                    } else {
                        ProgressView().tint(.gray)
                    }

                    Text(content)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color(UIColor.darkGray))
                        .multilineTextAlignment(.center).padding(.horizontal)
                }
            }
            .navigationTitle("Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(.black)
                }
            }
        }
        .onAppear {
            Task.detached(priority: .userInitiated) {
                let img = await generateQR(from: content)
                await MainActor.run { qrImage = img }
            }
        }
    }

    private func generateQR(from string: String) async -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        return UIImage(ciImage: scaled)
    }
}
