import Foundation

final class FavoritesStorage {
    static let shared = FavoritesStorage()
    private init() {}
    
    private(set) var favoriteProducts: [Product] = []

    func set(_ products: [Product]) {
        self.favoriteProducts = products
    }

    func add(_ product: Product) {
        if !favoriteProducts.contains(where: { $0.barcode == product.barcode }) {
            favoriteProducts.append(product)
        }
    }

    func remove(barcode: String) {
        favoriteProducts.removeAll { $0.barcode == barcode }
    }

    func isFavorite(_ barcode: String) -> Bool {
        return favoriteProducts.contains { $0.barcode == barcode }
    }
}

