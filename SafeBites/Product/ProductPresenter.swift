import Foundation

protocol ProductPresenterProtocol {
    func getProductInfo(with barcode: String)
}

final class ProductPresenter: ProductPresenterProtocol {
    weak var productVC: ProductViewProtocol?
    
    private let productService = ProductService.shared
    
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
                case .failure(let error):
                    self.productVC?.showErrorAlert(message: "Не получилось загрузить информацию о продукте")
                }
            }
        }
    }
}
