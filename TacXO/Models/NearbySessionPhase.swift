import Foundation

enum NearbySessionPhase: Equatable {
    case idle
    case advertising
    case browsing
    case connecting
    case playing
    case paused
}
