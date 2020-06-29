class Player {
    private var name: String
    private(set) var nickname: String
    var pods: Int
    
    init(name: String) {
        self.name = name
        self.nickname = name
        self.pods = 9
    }
}
