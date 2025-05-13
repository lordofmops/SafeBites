import Foundation

protocol FavoritesPresenterProtocol {
    var favoriteProducts: [Product] { get }
    func getFavorites()
    func addToFavorites(_ product: Product)
    func deleteFromFavorites(_ product: Product)
}

final class FavoritesPresenter: FavoritesPresenterProtocol {
    weak var favoritesVC: FavoritesViewProtocol?
    var favoriteProducts = FavoritesStorage.shared.favoriteProducts
    
    private let favoritesService = FavoritesService.shared
    private let productService = ProductService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    private let favoritesStorage = FavoritesStorage.shared
    
    init(favoritesVC: FavoritesViewProtocol) {
        self.favoritesVC = favoritesVC
    }
    
    func getFavorites() {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [FavoritesPresenter/getFavorites] No token found")
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
                        self.favoritesVC?.didFetchFavorites(favoriteProducts)
                    }
                case .failure(_):
                    self.favoritesVC?.showFavoritesErrorAlert(with: "Не получилось загрузить список избранных")
                }
            }
        }
    }
    
    func addToFavorites(_ product: Product) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [FavoritesPresenter/addToFavorites] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        favoritesService.addToFavorites(product.barcode, token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(()):
                    self.favoritesStorage.add(product)
                    self.favoritesVC?.didAddProductToFavorites(product)
                case .failure(_):
                    self.favoritesVC?.showFavoritesErrorAlert(with: "Не получилось добавить продукт в избранное")
                }
            }
        }
    }
    
    func deleteFromFavorites(_ product: Product) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [FavoritesPresenter/deleteFromFavorites] No token found")
            return
        }
        
        UIBlockingProgressHUD.show()
        
        favoritesService.deleteFromFavorites(product.barcode, token: token) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(()):
                    self.favoritesStorage.remove(barcode: product.barcode)
                    self.favoritesVC?.didRemoveProductFromFavorites(product)
                case .failure(_):
                    self.favoritesVC?.showFavoritesErrorAlert(with: "Не получилось удалить продукт из избранного")
                }
            }
        }
    }
}
