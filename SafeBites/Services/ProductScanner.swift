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
    private var captureSession: AVCaptureSession!
    private var hasScanned: Bool = false
    
    var isCameraAuthorized: Bool = false
    weak var delegate: ProductScannerDelegate?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    
    init(delegate: ProductScannerDelegate) {
        super.init()
        self.delegate = delegate
    }
    
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
        setupCaptureSession()
        hasScanned = false
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        } else {
            delegate?.didFailScanning(with: "Штрих-код не распознан")
            return
        }
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !hasScanned,
            let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let barcode = metadataObject.stringValue {
            hasScanned = true
            delegate?.didScanBarcode(barcode)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    // TODO: возможно можно разделить на первичное и рестарт сессии
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let backCameraDevice = AVCaptureDevice.default(for: .video) else { return }
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: backCameraDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            delegate?.didFailScanning(with: "Ваше устройство не поддерживает сканирование")
            return
        }
        
        DispatchQueue.main.async {
            self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.cameraPreviewLayer.videoGravity = .resizeAspectFill
        }
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
}
