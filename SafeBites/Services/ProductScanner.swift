import AVFoundation

protocol ProductScannerDelegate: AnyObject {
    func didScanBarcode(_ barcode: String)
    func didFailScanning(with message: String)
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer
}

protocol ProductScanning {
    var isCameraAuthorized: Bool { get }
    var delegate: ProductScannerDelegate? { get }
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer! { get }
    
    func scanProduct()
    func setupCamera(completion: @escaping () -> Void)
}

final class ProductScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate, ProductScanning {
    static let shared = ProductScanner()
    
    private var captureSession: AVCaptureSession!
    private var hasScanned: Bool = true
    
    var isCameraAuthorized: Bool = false
    weak var delegate: ProductScannerDelegate?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private override init() {}
    
    func setupCamera(completion: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { response in
                self.isCameraAuthorized = response
                if response {
                    DispatchQueue.global().async {
                        self.setupCaptureSession()
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.didFailScanning(with: "Нет доступа к камере")
                    }
                }
            }
        } else {
            isCameraAuthorized = true
            setupCaptureSession()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func scanProduct() {
        guard let captureSession, captureSession.isRunning  else {
            delegate?.didFailScanning(with: "Сессия захвата не запущена")
            return
        }
        
        hasScanned = false
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !hasScanned,
            let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let barcode = metadataObject.stringValue {
            print("Barcode: \(barcode)")
            hasScanned = true
            delegate?.didScanBarcode(barcode)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    // TODO: возможно можно разделить на первичное и рестарт сессии
    private func setupCaptureSession() {
        guard captureSession == nil else { return }
        
        captureSession = AVCaptureSession()
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            delegate?.didFailScanning(with: "Камера недоступна")
            return
        }
        
        guard let captureSession else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            delegate?.didFailScanning(with: "Ваше устройство не поддерживает сканирование")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            delegate?.didFailScanning(with: "Штрих-код не распознан")
            return
        }
        
        DispatchQueue.main.async {
            self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.cameraPreviewLayer.videoGravity = .resizeAspectFill
            
            if self.captureSession?.isRunning == false {
                self.captureSession.startRunning()
            }
        }
        print("Capture session is running: \(captureSession.isRunning)")
    }
}
