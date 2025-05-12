import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private variables
    private let authService = AuthService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        if let _ = authTokenStorage.token {
            UIBlockingProgressHUD.show()
//            self.fetchProfile {
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
//            }
            
        } else {
            showAuthScreen()
        }
    }
    
    private func showAuthScreen() {
        guard authTokenStorage.token == nil else { return }
        
        let authScreen = AuthViewController()
        
        let navigationController = UINavigationController(rootViewController: authScreen)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[ERROR] [SplashViewController/switchToTabBarController]: Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
           
        window.rootViewController = tabBarController
    }
}

