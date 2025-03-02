import UIKit
import AVFoundation

final class ScanningViewController: UIViewController,
                                    ScanningView {
    // MARK: Private variables
    private var presenter: ScanningPresenter!
    
    // UI elements
    private lazy var cameraView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        
        view.backgroundColor = UIColor(named: "Black")
        
        return view
    }()
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(named: "Black")
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        
        button.setTitle("Сканировать штрих-код", for: .normal)
        button.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        
        button.addTarget(self, action: #selector(didTapScanButton), for: .touchUpInside)
        
        return button
    }()
    private lazy var detectedAllergensTextView: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = UIColor(named: "Gray")
        textView.layer.cornerRadius = 24
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 19, left: 16, bottom: 10, right: 16)
        
        let fullText = NSMutableAttributedString()
        let line = NSAttributedString(string: "Для проверки продукта отсканируйте штрих-код", attributes: [
            .font: UIFont(name: "SourceSansPro-Regular", size: 20)!,
            .foregroundColor: UIColor(named: "White") ?? .white
        ])
        fullText.append(line)
        textView.attributedText = fullText
        
        return textView
    }()
    private lazy var seeDetailedInfoButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(named: "Silver")
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        
        button.setTitle("Посмотреть полную информацию", for: .normal)
        button.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor(named: "Background"), for: .normal)
        
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Background")
        
        presenter = ScanningPresenter(view: self)
        
        setupCameraView()
        setupScanButton()
        setupDetailedInfoButton()
        setupAllergensTextView()
        
        presenter.setupScanning {
            DispatchQueue.main.async {
                let cameraPreviewLayer = self.presenter.getPreviewLayer()
                cameraPreviewLayer.frame = self.cameraView.bounds
                self.cameraView.layer.addSublayer(cameraPreviewLayer)
                print("Camera preview layer added: \(cameraPreviewLayer != nil)")
            }
        }
//        presenter.setupScanning()
    }
    
    // MARK: UI setup
    // Updating information about allergens after scanning barcode
    func updateAllergensInfo(for product: Allergens) {
        let name = product.name
        let allergens = product.allergens
        
        let fullText = NSMutableAttributedString()
        
        // Adding title
        let titleAttributed = NSAttributedString(string: "\(name) \nНайденные аллергены: \n\n", attributes: [
            .font: UIFont(name: "SourceSansPro-Bold", size: 20)!,
            .foregroundColor: UIColor(named: "White") ?? .white
        ])
        fullText.append(titleAttributed)
        
        switch allergens.isEmpty {
        case true:
            let carrotAttachment = NSTextAttachment()
            carrotAttachment.image = UIImage(systemName: "carrot.fill")?.withTintColor(.orange)
            carrotAttachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 16)
            let carrotIcon = NSAttributedString(attachment: carrotAttachment)
            
            fullText.append(carrotIcon)
            
            let line = NSAttributedString(string: " Данный продукт не содержит аллергенов :)", attributes: [
                .font: UIFont(name: "SourceSansPro-Regular", size: 16)!,
                .foregroundColor: UIColor(named: "White") ?? .white
            ])
            fullText.append(line)
            detectedAllergensTextView.attributedText = fullText
            view.layoutIfNeeded()
            return
        case false:
            let exclamationAttachment = NSTextAttachment()
            exclamationAttachment.image = UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(UIColor(named: "Red") ?? .red)
            exclamationAttachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 16)
            let icon = NSAttributedString(attachment: exclamationAttachment)
            
            for line in allergens {
                // Adding icon before each line
                fullText.append(icon)
                
                let line = NSAttributedString(string: " \(line)\n", attributes: [
                    .font: UIFont(name: "SourceSansPro-Regular", size: 16)!,
                    .foregroundColor: UIColor(named: "White") ?? .white
                ])
                fullText.append(line)
            }
            
            detectedAllergensTextView.attributedText = fullText
            view.layoutIfNeeded()
        }
    }
    
    // Setup UI elements
    // TODO: продумать, что делать, если пользователь не дает доступ к камере и остается на странице
    private func setupCameraView() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cameraView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            cameraView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        let cameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
        
        cameraIcon.tintColor = UIColor(named: "White")
        cameraIcon.contentMode = .scaleAspectFit
        
        cameraIcon.translatesAutoresizingMaskIntoConstraints = false
        cameraView.addSubview(cameraIcon)
        
        NSLayoutConstraint.activate([
            cameraIcon.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
            cameraIcon.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
            cameraIcon.widthAnchor.constraint(equalToConstant: 36),
            cameraIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupScanButton() {
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            scanButton.heightAnchor.constraint(equalToConstant: 44),
            
            scanButton.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            scanButton.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
            scanButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 18)
        ])
    }
    
    private func setupAllergensTextView() {
        detectedAllergensTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detectedAllergensTextView)
        
        NSLayoutConstraint.activate([
            detectedAllergensTextView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 18),
            detectedAllergensTextView.bottomAnchor.constraint(equalTo: seeDetailedInfoButton.topAnchor, constant: -18),
            detectedAllergensTextView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            detectedAllergensTextView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor)
        ])
    }
    
    private func setupDetailedInfoButton() {
        detectedAllergensTextView.isUserInteractionEnabled = false
        detectedAllergensTextView.isScrollEnabled = true
        
        seeDetailedInfoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seeDetailedInfoButton)
        
        NSLayoutConstraint.activate([
            seeDetailedInfoButton.heightAnchor.constraint(equalToConstant: 44),
            
            seeDetailedInfoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            seeDetailedInfoButton.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            seeDetailedInfoButton.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor)
        ])
    }
    
    // Button actions
    @objc
    private func didTapScanButton() {
        presenter.didTapScanButton()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "ОК", style: .default)))
        present(alert, animated: true)
    }
}
