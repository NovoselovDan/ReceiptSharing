enum Command: Codable {
    case newSession(userName: String)
    case addSelection(ItemId)
    case removeSelection(ItemId)
    case complete
}
