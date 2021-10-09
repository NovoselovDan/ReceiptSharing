import Foundation

typealias ItemId = UUID

struct Item: Codable {
    var id = ItemId()
    let title: String
    let price: Double
    var selections: [Selection] = []
}
