import Foundation

protocol SearchPresenterProtocol: AnyObject {
    func searchProducts(query: String?, filters: SearchFilters?, page: Int)
}

final class SearchPresenter: SearchPresenterProtocol {
    private weak var view: SearchViewProtocol?
    private let service: SearchServiceProtocol

    init(view: SearchViewProtocol, service: SearchServiceProtocol = SearchService.shared) {
        self.view = view
        self.service = service
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
//                    let filtered = self?.applyFilters(products: products, filters: filters) ?? []
                    self.view?.showProducts(products)
                    self.view?.updatePaginationButtons(totalPages: self.service.totalPages)
                case .failure(_):
                    self.view?.showError("Попробуйте еще раз")
                }
            }
        }
    }

//    private func applyFilters(products: [Product], filters: SearchFilters?) -> [Product] {
//        guard let filters else { return products }
//
//        return products.filter { product in
//            let isVeganOK = !filters.onlyVegan || product.veganSuitability == .suitable
//            let isVegetarianOK = !filters.onlyVegetarian || product.vegetarianSuitability == .suitable
//            let hasConflictingAllergens = (product.allergens ?? []).contains { filters.excludedAllergens.contains($0) }
//
//            return isVeganOK && isVegetarianOK && !hasConflictingAllergens
//        }
//    }
}

