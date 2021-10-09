enum Event {
    case initial(InitialData)
    case updateItems([Item])
    case updateUsers([User])
}
