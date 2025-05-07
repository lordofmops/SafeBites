import Foundation

protocol RegistrationPresenterProtocol {
    func register(email: String, password: String, name: String?)
}

final class RegistrationPresenter: RegistrationPresenterProtocol {
    weak var registrationVC: RegistrationViewProtocol?
    
    private let registrationService = RegistrationService.shared
    private let authService = AuthService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    private var user: User?
    
    init(registrationVC: RegistrationViewProtocol) {
        self.registrationVC = registrationVC
    }
    
    func register(email: String, password: String, name: String?) {
        UIBlockingProgressHUD.show()
        
        registrationService.register(email: email, password: password, name: name) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    print("[INFO] User \(user.email) successfully registered")
                    self.authService.login(email: email, password: password) { [weak self] result in
                        guard let self, let user = self.user else {
                            UIBlockingProgressHUD.dismiss()
                            return
                        }
                        
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss()
                            
                            switch result {
                            case .success(let token):
                                self.authTokenStorage.token = token
                                self.registrationVC?.didRegister(user: user, token: token)
                                print("[INFO] User \(user.email) successfully logged in")
                            case .failure(_):
                                self.registrationVC?.showRegistrationErrorAlert(message: "Не получилось войти в профиль")
                            }
                        }
                    }
                case .failure(_):
                    self.registrationVC?.showRegistrationErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
}
