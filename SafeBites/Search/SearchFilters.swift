import Foundation

struct SearchFilters: Equatable {
    var excludedAllergens: [String]
    var onlyVegan: Bool
    var onlyVegetarian: Bool
}
