class Player {
    private var name: String
    var nickname: Character
    var pods: Int
    
    init(name: String) {
        self.name = name
        self.nickname = Array(name) [0]
        self.pods = 9
    }
}
