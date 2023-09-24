import Foundation

enum FilterCase {
    case none
    case favorite
    case search

    var title: String? {
        switch self {
        case .none:
            return nil
        case .favorite:
            return "Favorites"
        case .search:
            return "Found"
        }
    }
}
