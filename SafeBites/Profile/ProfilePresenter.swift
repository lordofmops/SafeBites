import Foundation

protocol ProfilePresenterProtocol {
    func fetchProfile()
    func updateName(updatedName: String)
    func deleteProfile()
    func addRestriction(id: UUID)
    func removeRestriction(id: UUID)
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var profileVC: ProfileViewProtocol?
    
    private let profileService: ProfileServiceProtocol = ProfileService.shared
    private let restrictionService: RestrictionsServiceProtocol = RestrictionsService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    
    init(profileVC: ProfileViewProtocol) {
        self.profileVC = profileVC
    }
    
    func fetchProfile() {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProfilePresenter/fetchProfile] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("[INFO] User \(user.email) profile successfully fetched")
                    self.restrictionService.getUserRestrictions(for: token) { [weak self] result in
                        guard let self else {
                            UIBlockingProgressHUD.dismiss()
                            return
                        }
                        
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss()
                            
                            switch result {
                            case .success(let restrictions):
                                self.profileVC?.didFetchProfile(user: user, restrictions: restrictions)
                                print("[INFO] User \(user.email) profile successfully fetched")
                            case .failure(_):
                                self.profileVC?.showProfileErrorAlert(message: "Не получилось загрузить профиль")
                            }
                        }
                    }
                case .failure(_):
                    self.profileVC?.showProfileErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
    
    func updateName(updatedName: String) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProfilePresenter/fetchProfile] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        self.profileService.updateName(token: token, updatedName: updatedName) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let user):
                    self.profileVC?.updateUsername(updatedUsername: user.name ?? "no name")
                    print("[INFO] Profile name successfully updated")
                case .failure(_):
                    self.profileVC?.showProfileErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
    
    func deleteProfile() {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProfilePresenter/fetchProfile] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        self.profileService.deleteProfile(token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success():
                    self.profileVC?.didDeleteProfile()
                    print("[INFO] Profile successfully deleted")
                case .failure(_):
                    self.profileVC?.showProfileErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
    
    func addRestriction(id: UUID) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProfilePresenter/fetchProfile] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        self.profileService.addRestriction(id: id, token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let restrictions):
                    self.profileVC?.didUpdateRestrictions(restrictions)
                    print("[INFO] User restriction successfully added")
                case .failure(_):
                    self.profileVC?.showProfileErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
    
    func removeRestriction(id: UUID) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProfilePresenter/fetchProfile] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        self.profileService.removeRestriction(id: id, token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let restrictions):
                    self.profileVC?.didUpdateRestrictions(restrictions)
                    print("[INFO] User restriction successfully removed")
                case .failure(_):
                    self.profileVC?.showProfileErrorAlert(message: "Что-то пошло не так")
                }
            }
        }
    }
    
    func logout() {
        profileVC?.showLogoutAlert()
    }
}
