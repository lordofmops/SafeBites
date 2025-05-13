import Foundation

protocol SplashPresenterProtocol {
    func getFavorites(completion: @escaping () -> Void)
}

final class SplashPresenter: SplashPresenterProtocol {
    private let favoritesService = FavoritesService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    private let favoritesStorage = FavoritesStorage.shared
    private let productService = ProductService.shared
    
    func getFavorites(completion: @escaping () -> Void) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [SplashPresenter/getFavorites] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        favoritesService.getFavorites(token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let favoritesBarcodes):
                    var favoriteProducts: [Product] = []
                    let group = DispatchGroup()
                    
                    for barcode in favoritesBarcodes {
                        group.enter()
                        self.productService.getProductInfo(with: barcode) { result in
                            if case .success(let product) = result {
                                favoriteProducts.append(product)
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        UIBlockingProgressHUD.dismiss()
                        self.favoritesStorage.set(favoriteProducts)
                    }
                case .failure(_):
                    print("[ERROR] [SplashPresenter/getFavorites] Failed to get favorites")
                }
            }
            completion()
        }
    }
}
