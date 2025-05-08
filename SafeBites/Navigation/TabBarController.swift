import UIKit
 
final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
            
        let scanningViewController = ScanningViewController()
        let scanningNavigationController = UINavigationController(rootViewController: scanningViewController)
        scanningViewController.tabBarItem = UITabBarItem(
            title: "Сканер",
            image: UIImage(systemName: "barcode.viewfinder"),
            selectedImage: UIImage(systemName: "barcode.viewfinder")
        )
           
        self.viewControllers = [scanningNavigationController]
    }
    
    private func setupUI() {
        self.tabBar.backgroundColor = .sbBackground
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.sbGray.cgColor
        self.tabBar.tintColor = .sbWhite
        self.tabBar.unselectedItemTintColor = .sbSilver

    }
}
