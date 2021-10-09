enum Event: Codable {
    case initial(InitialData)
    case updateItems([Item])
    case updateUsers([User])
}
