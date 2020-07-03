class Player {
    private var name: String
    var nickname: Character
    var pawns: Int
    
    init(name: String) {
        self.name = name
        self.nickname = Array(name) [0]
        self.pawns = 9
    }
}
