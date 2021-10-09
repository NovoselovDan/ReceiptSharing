import Foundation

typealias UserId = UUID
typealias ColorId = Int

struct User: Codable {
    var id = UserId()
    let name: String
    let colorHex: String
    var finished: Bool
}
