class Playground {
    private(set) var firstPlayer: Player
    private(set) var secondPlayer: Player
    private(set) var game: Game
    
    init(firstPlayer: Player, secondPlayer: Player){
        self.firstPlayer = firstPlayer;
        self.secondPlayer = secondPlayer
        self.game = Game()
    }
    
    func startGame() -> Void {
        print("Nine men's morris")
        
        printBoard()
        
        // Each player has 9 moves
        var initialMoves = 9 // TODO: make global constant
        while initialMoves > 0 {
            move(true, firstPlayer, secondPlayer);
            move(true, secondPlayer, firstPlayer);
            initialMoves = initialMoves - 1
            print("Init moves: ", initialMoves)
        }
        
        while true { // TODO: condition is to have at least 3 pods
            move(false, firstPlayer, secondPlayer);
            move(false, secondPlayer, firstPlayer);
        }
        
    }
    
    func move(_ isInitialMove: Bool, _ firstPlayer: Player, _ secondPlayer: Player) -> Void {
        print("Player ", firstPlayer.nickname)
        
        let input = readLine()
        let coordinates = Array(input!)
        if(!areValidCoordinates(coordinates, isInitialMove)) {
            print("Invalid move") // DODO: make constant INVALID_MOVE_MSG
            move(isInitialMove, firstPlayer, secondPlayer)
            return
        }
        
        makeMove(isInitialMove, coordinates, fdebug", irstPlayer, secondPlayer)
        
    }
    
    func makeMove(_ isInitialMove: Bool, _ coordinates: [Character], _ firstPlayer: Player, _ secondPlayer: Player) -> Void {
        // TODO: converting X and Y twice (here and in isLegalMove)
        if(!isLegalMove(coordinates)) {
            print("Invalid move")
            move(isInitialMove, firstPlayer, secondPlayer)
            return;
        }
        
        let xCoordinate: Int
        let yCoordinate: Int
        
        if(isInitialMove) {
            xCoordinate = getX(coordinates[0])
            yCoordinate = Int(String(coordinates[1]))! - 1 // starts counting from 0
        }else{
            let oldXCoordinate = getX(coordinates[0])
            let oldYCoordinate = Int(String(coordinates[1]))! - 1
            
            game.board[oldXCoordinate][oldYCoordinate] = "o" // make constant FREE_POSITION
            
            xCoordinate = getX(coordinates[2])
            yCoordinate = Int(String(coordinates[3]))! - 1
        }
        
        let firstPlayerNickname = firstPlayer.nickname
        game.board[xCoordinate][yCoordinate] = firstPlayerNickname
        printBoard()
        
        if hasThreePods(xCoordinate, yCoordinate, firstPlayerNickname) {
            removePod(firstPlayerNickname, secondPlayer)
        }
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

    
    func isLegalMove(_ coordinates: [Character]) -> Bool {
        let xCoordinate = getX(coordinates[0])
        let yCoordinate = Int(String(coordinates[1]))! - 1
        
        // verify boundaries
        let boardSize = game.board.count
        if xCoordinate >= boardSize || xCoordinate < 0 || yCoordinate >= boardSize || yCoordinate < 0 {
            return false
        }
        
        // verify that the chosen position is legal
        let value = game.board[xCoordinate][yCoordinate]
        if value == "X" || value == "|" || value == "-" { // TODO: constants
            return false
        }
        return true
    }
    
    func getX(_ xCoordinate: Character) -> Int {
        switch xCoordinate {
        case "A":
            return 0
        case "B":
            return 1
        case "C":
            return 2
        case "D":
            return 3
        case "E":
            return 4
        case "F":
            return 5
        case "G":
            return 6
        default:
            return 0 // TODO: fix default case
        }
    }
    
    func hasThreePods(_ xCoordinate: Int, _ yCoordinate: Int, _ playerNickname: Character) -> Bool {
        // middle rows are handled differently
        if xCoordinate == 3 || yCoordinate == 3 {
            return checkAllPossibilities(xCoordinate, yCoordinate, [], playerNickname, true)
        }
        
        let possibilities = getPossibilities(xCoordinate)
        return checkAllPossibilities(xCoordinate, yCoordinate, possibilities, playerNickname, false)
    }
    
    func checkAllPossibilities(_ xCoordinate: Int, _ yCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character, _ isMiddleRow: Bool) -> Bool {
        if isMiddleRow {
            return checkAllPossibilitiesForMiddleRow(xCoordinate, yCoordinate, playerNickname)
        }
        return checkHorizontally(xCoordinate, possibilities, playerNickname) || checkVertically(yCoordinate, possibilities, playerNickname)
    }
    
    func checkAllPossibilitiesForMiddleRow(_ xCoordinate: Int, _ yCoordinate: Int, _ playerNickname: Character) -> Bool {
        print("debug here")
        var hasThreePodsHorizontally = false
        var hasThreePodsVertically = false
        
        if xCoordinate == 3 {
            if yCoordinate < 3 {
                hasThreePodsHorizontally = checkHorizontally(xCoordinate, [0,1,2], playerNickname)
            } else {
                hasThreePodsHorizontally = checkHorizontally(xCoordinate, [4, 5, 6], playerNickname)
            }
            let possibilities = getPossibilities(yCoordinate)
            hasThreePodsVertically = checkVertically(yCoordinate, possibilities, playerNickname)
        }
        
        if yCoordinate == 3 {
            if xCoordinate < 3 {
                hasThreePodsVertically = checkVertically(yCoordinate, [0,1,2], playerNickname)
            } else {
                hasThreePodsVertically = checkVertically(yCoordinate, [4, 5, 6], playerNickname)
            }
            let possibilities = getPossibilities(yCoordinate)
            hasThreePodsVertically = checkVertically(yCoordinate, possibilities, playerNickname)
        }
        
        print("debug", hasThreePodsHorizontally)
        print("debug", hasThreePodsVertically)
        return hasThreePodsHorizontally || hasThreePodsVertically
    }

    func checkVertically(_ yCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character) -> Bool{
        print("Possibilities: ", possibilities)
        for possibility in possibilities {
            if(game.board[possibility][yCoordinate] != playerNickname) {
                return false
            }
        }
        return true
    }
    
    func checkHorizontally(_ xCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character) -> Bool {
        for possibility in possibilities {
            if(game.board[xCoordinate][possibility] != playerNickname) {
                return false
            }
        }
        return true
    }
    
    func getPossibilities(_ coordinate: Int) -> [Int] {
        switch coordinate {
        case 0, 6:
            return [0,3,6]
        case 1, 5:
            return [1, 3, 5]
        case 2, 4:
            return [2, 3, 4]
        default:
            return [] // TODO: fix default case
        }
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
        
        print()
    }
    
    func removePod(_ firstPlayerNickname: Character, _ secondPlayer: Player) -> Void {
        print("Please, choose a pod to be removed")
        let input = readLine()
        let coordinates = Array(input!)
        
        let xCoordinate = getX(coordinates[0])
        let yCoordinate = Int(String(coordinates[1]))! - 1

        if !isLegalMove(coordinates) || game.board[xCoordinate][yCoordinate] != secondPlayer.nickname {
            print("Invalid move")
            removePod(firstPlayerNickname, secondPlayer) // TODO: use while loop instead of calling the same function
            return
        }
        
        game.board[xCoordinate][yCoordinate] = "o" // TODO: constant
        
        if hasEnoughPods(secondPlayer) {
            endGame(firstPlayerNickname)
            return
        }
        
        secondPlayer.pods = secondPlayer.pods - 1
        printBoard()
    }
    
    func hasEnoughPods(_ player: Player) -> Bool {
        return player.pods > 2
    }
    
    func endGame(_ winner: Character) -> Void {
        print("Game over")
        print(winner, " won!")
    }
    
}
