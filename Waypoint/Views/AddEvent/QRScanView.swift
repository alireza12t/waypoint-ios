import SwiftUI
import AVFoundation

struct QRScanView: View {
    let onScan: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScannerRepresentable { value in
                    onScan(value)
                    dismiss()
                }
                .ignoresSafeArea()

                // Viewfinder overlay
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.waypointAmber, lineWidth: 3)
                        .frame(width: 260, height: 260)
                    Text("Point at a QR code or barcode")
                        .font(.subheadline).foregroundStyle(.white)
                        .padding(10).background(.black.opacity(0.55)).clipShape(Capsule())
                        .padding(.top, 20)
                    Spacer()
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - UIKit Bridge

private struct ScannerRepresentable: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onScan = onScan
        return vc
    }
    func updateUIViewController(_ vc: ScannerViewController, context: Context) {}
}

// MARK: - Scanner ViewController

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScan: ((String) -> Void)?

    private let session = AVCaptureSession()
    private var preview: AVCaptureVideoPreviewLayer?
    private var didScan = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        Task { await setupCamera() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task.detached(priority: .utility) { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func setupCamera() async {
        guard await AVCaptureDevice.requestAccess(for: .video) else { return }
        guard let device = AVCaptureDevice.default(for: .video),
              let input  = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr, .aztec, .pdf417, .code128, .code39, .dataMatrix, .ean13, .ean8]
        session.commitConfiguration()

        await MainActor.run {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            preview = layer
        }

        Task.detached(priority: .userInitiated) { [weak self] in
            self?.session.startRunning()
        }
    }

    // MARK: - Delegate

    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput objects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let obj = objects.first as? AVMetadataMachineReadableCodeObject,
              let val = obj.stringValue else { return }
        Task { @MainActor [weak self] in
            guard let self, !self.didScan else { return }
            self.didScan = true
            Task.detached(priority: .utility) { [weak self] in self?.session.stopRunning() }
            self.onScan?(val)
        }
    }
}
