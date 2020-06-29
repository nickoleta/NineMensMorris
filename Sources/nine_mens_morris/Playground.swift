class Playground {
    private(set) var firstPlayer: Player
    private(set) var secondPlayer: Player
    private(set) var game: Game
    
    init(firstPlayer: Player, secondPlayer: Player){
        self.firstPlayer = firstPlayer;
        self.secondPlayer = secondPlayer
        self.game = Game()
    }
    
    func printBoard() -> Void {
        var board = game.board
        
        // TODO: refactor this piece of code
        
        // print x column coordinates
        print("  ", terminator: "")
        for column in 0...6 {
            print(column + 1, terminator: "")
        }
        
        print()
        
        // print board
        let rows = ["A", "B", "C", "D", "E", "F", "G"]
        for x in (0..<board.count) { // TODO: refactor
            // print rows
            print(rows[x], terminator: "")
            print(" ", terminator: "")
            
            for y in (0..<board[x].count) {
                print(board[x][y], terminator:"")
            }
            print()
        }
    }
}
