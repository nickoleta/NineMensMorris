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
        print()
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
    
    func startGame() -> Void {
        print("Nine men's morris")
        
        printBoard()
        
        // Each player has 9 moves
        var initialMoves = 18 // TODO: make global constant
        while initialMoves > 0 {
            //    move(board, firstPlayer, secondPlayer, true);
            //    move(board, secondPlayer, secondPlayer, true);
            initialMoves = initialMoves - 1
        }
        
        while true { // TODO: condition is to have at least 3 pods
            //    move(board, firstPlayer, secondPlayer, false);
            //    move(board, secondPlayer, secondPlayer, false);
        }
        
    }
    
    func move(_ isInitialMove: Bool) -> Void {
        print("Player " + firstPlayer.nickname)
        
        let input = readLine()
        let coordinates = Array[input]
        if(!areValidCoordinates(coordinates, isInitialMove)) {
            print("Invalid move") // DODO: make constant INVALID_MOVE_MSG
            move(isInitialMove)
            return
        }
        
        makeMove(isInitialMove)
        
    }
    
    func makeMove(_ isInitialMove: Bool) -> Void {
        // TODO
    }
    
    func areValidCoordinates(_ coordinates: [Character], _ isInitialMove: Bool) -> Bool {
        if isInitialMove {
            if coordinates.count != 2 {
                return false;
            }
        }
        else {
            if coordinates.count != 4 {
                return false;
            }
            
            // TODO: eliminate illegal moves
            // TODO: player A can move pods of player B
        }
        
        // TODO: check if chars are digits between 0 and 6
        return true;
    }
}
