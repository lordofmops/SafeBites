import Foundation

protocol ProductPresenterProtocol {
    func getProductInfo(with barcode: String)
    func isFavorite(barcode: String) -> Bool
    func addToFavorite(_ product: Product)
    func deleteFromFavorites(_ product: Product)
}

final class ProductPresenter: ProductPresenterProtocol {
    weak var productVC: ProductViewProtocol?
    
    let productService = ProductService.shared
    let authTokenStorage = AuthTokenStorage.shared
    let favoritesService = FavoritesService.shared
    let favoritesStorage = FavoritesStorage.shared
    
    init(productVC: ProductViewProtocol) {
        self.productVC = productVC
    }
    
    func getProductInfo(with barcode: String) {
        UIBlockingProgressHUD.show()
        
        productService.getProductInfo(with: barcode) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let product):
                    self.productVC?.didFetchProductInfo(product)
                case .failure(_):
                    self.productVC?.showErrorAlert(message: "Не получилось загрузить информацию о продукте")
                }
            }
        }
    }
    
    func isFavorite(barcode: String) -> Bool {
        favoritesStorage.isFavorite(barcode)
    }
    
    func addToFavorite(_ product: Product) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProductPresenter/addToFavorite] No token found")
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
                case .failure(_):
                    self.productVC?.showErrorAlert(message: "Не получилось добавить продукт в избранное")
                }
            }
        }
    }
    
    func deleteFromFavorites(_ product: Product) {
        guard let token = authTokenStorage.token else {
            print("[ERROR] [ProductPresenter/deleteFromFavorites] No token found")
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
                case .failure(_):
                    self.productVC?.showErrorAlert(message: "Не получилось удалить продукт из избранного")
                }
            }
        }
    }
}
