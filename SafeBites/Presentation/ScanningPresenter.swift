import AVFoundation

protocol ScanningView: AnyObject {
    func updateAllergensInfo(for: Allergens)
    func showAlert(title: String, message: String)
}

final class ScanningPresenter: ProductScannerDelegate {
    private weak var view: ScanningView?
    private let productLoader: ProductLoading = ProductLoader.shared
    private lazy var scanner: ProductScanner = ProductScanner.shared
    private var hasScanned = true
    
    init(view: ScanningView) {
        self.view = view
        scanner.delegate = self
    }
    
    func setupScanning(completion: @escaping () -> Void) {
        scanner.setupCamera(completion: completion)
    }
    
    func didTapScanButton() {
        scanner.scanProduct()
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
//        if scanner.cameraPreviewLayer == nil {
//            scanner.setupCamera()
//        }
        return scanner.cameraPreviewLayer
    }
    
    // MARK: ProductScannerDelegate
    func didScanBarcode(_ barcode: String) {
        productLoader.fetchAllergens(for: barcode) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let product):
                    self.view?.updateAllergensInfo(for: product)
                case .failure(let error):
                    self.view?.showAlert(title: "Не получилось отсканировать код :(", message: "Ошибка загрузки данных")
                }
            }
        }
    }
    
    func didFailScanning(with message: String) {
        view?.showAlert(title: "Не получилось отсканировать код :(", message: message)
    }
}
