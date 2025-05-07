import UIKit

protocol ProductViewProtocol: AnyObject {
    func didFetchProductInfo(_ product: Product)
    func showErrorAlert(message: String)
}

final class ProductViewController: UIViewController {
    
}

extension ProductViewController: ProductViewProtocol {
    func didFetchProductInfo(_ product: Product) {
        //TODO: обновить UI
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка :(", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "Попробовать еще раз", style: .default)))
        present(alert, animated: true)
    }
}
