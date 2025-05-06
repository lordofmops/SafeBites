import Foundation

protocol AuthPresenterProtocol: AnyObject {
    func login(email: String, password: String)
}

final class AuthPresenter: AuthPresenterProtocol {
    weak var authVC: AuthViewProtocol?
    
    private let authService: AuthServiceProtocol = AuthService.shared
    
    init(authVC: AuthViewProtocol) {
        self.authVC = authVC
    }
    
    func login(email: String, password: String) {
        UIBlockingProgressHUD.show()
        authService.login(email: email, password: password) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let token):
                    self.authVC?.didAuthenticated(token: token)
                case .failure(let error):
                    self.authVC?.showAuthErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
}
