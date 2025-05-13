import Foundation

protocol SearchPresenterProtocol: AnyObject {
    func searchProducts(query: String?, filters: SearchFilters?, page: Int)
}

final class SearchPresenter: SearchPresenterProtocol {
    private weak var searchVC: SearchViewProtocol?
    private let service: SearchServiceProtocol = SearchService.shared

    init(searchVC: SearchViewProtocol) {
        self.searchVC = searchVC
    }

    func searchProducts(query: String?, filters: SearchFilters? = nil, page: Int) {
        UIBlockingProgressHUD.show()
        
        service.searchProducts(query: query, filters: filters, page: page) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let products):
                    self.searchVC?.showProducts(products)
                    self.searchVC?.updatePaginationButtons(totalPages: self.service.totalPages)
                case .failure(_):
                    self.searchVC?.showError("Попробуйте еще раз")
                }
            }
        }
    }
}

