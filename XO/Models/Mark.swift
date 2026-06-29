import Foundation

enum Mark: String, Codable, Equatable {
    case x
    case o

    var opponent: Mark {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }

    var label: String {
        rawValue.uppercased()
    }
}
