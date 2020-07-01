class Playground {
    let INITIAL_MOVES_COUNT = 9;
    let FREE_POSITION : Character = "o"
    let INVALID_MOVE_MSG = "Invalid move!"
    
    private(set) var firstPlayer: Player
    private(set) var secondPlayer: Player
    private(set) var game: Game
    
    init(firstPlayer: Player, secondPlayer: Player){
        self.firstPlayer = firstPlayer
        self.secondPlayer = secondPlayer
        self.game = Game()
    }
    
    // TODO: You cannot take a pod that is part of a threesome
    
    func startGame() -> Void {
        print("Nine men's morris")
        
        printBoard()
        
        // Each player has 9 moves
        var initialMoves = INITIAL_MOVES_COUNT
        while initialMoves > 0 {
            move(true, firstPlayer, secondPlayer)
            move(true, secondPlayer, firstPlayer)
            initialMoves = initialMoves - 1
            print("Init moves: ", initialMoves)
        }
        
        repeat {
            move(false, firstPlayer, secondPlayer)
            if !hasEnoughPods(secondPlayer) {
                endGame()
                return
            }
            move(false, secondPlayer, firstPlayer)
        } while hasEnoughPods(firstPlayer)
        
        endGame()
    }
    
    func move(_ isInitialMove: Bool, _ firstPlayer: Player, _ secondPlayer: Player) -> Void {
        var coordinates: [Character]
        repeat {
            print("Player ", firstPlayer.nickname)
            
            let input = readLine()
            coordinates = Array(input!)
        } while !areValidCoordinates(coordinates, isInitialMove)
        
        makeMove(isInitialMove, coordinates, firstPlayer, secondPlayer)
    }
    
    func makeMove(_ isInitialMove: Bool, _ coordinates: [Character], _ firstPlayer: Player, _ secondPlayer: Player) -> Void {
        // TODO: converting X and Y twice (here and in isLegalMove)
        if(!isLegalMove(coordinates)) {
            print(INVALID_MOVE_MSG)
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
            
            game.board[oldXCoordinate][oldYCoordinate] = FREE_POSITION
            
            xCoordinate = getX(coordinates[2])
            yCoordinate = Int(String(coordinates[3]))! - 1
        }
        
        let firstPlayerNickname = firstPlayer.nickname
        game.board[xCoordinate][yCoordinate] = firstPlayerNickname
        printBoard()
        
        if hasThreePods(xCoordinate, yCoordinate, firstPlayerNickname) {
            removePod(firstPlayerNickname, secondPlayer)
            printBoard()
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
        if value == "X" || value == "|" || value == "-" {
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
            let possibilities = getPossibilities(xCoordinate)
            hasThreePodsHorizontally = checkHorizontally(xCoordinate, possibilities, playerNickname)
        }
        
        return hasThreePodsHorizontally || hasThreePodsVertically
    }

    func checkVertically(_ yCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character) -> Bool{
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
        
        // print x column coordinates
        print("  ", terminator: "")
        for column in 0...6 {
            print(column + 1, terminator: "")
        }
        
        print()
        
        // print board
        let rows = ["A", "B", "C", "D", "E", "F", "G"]
        for x in (0..<board.count) {
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
        var coordinates: [Character]
        var xCoordinate: Int
        var yCoordinate: Int
        repeat {
            print("Please, choose a pod to be removed")
            let input = readLine()
            coordinates = Array(input!)

            xCoordinate = getX(coordinates[0])
            yCoordinate = Int(String(coordinates[1]))! - 1
        } while !isLegalMove(coordinates) || game.board[xCoordinate][yCoordinate] != secondPlayer.nickname

        game.board[xCoordinate][yCoordinate] = FREE_POSITION
        
        if !hasEnoughPods(secondPlayer) {
            endGame()
            return
        }

        secondPlayer.pods = secondPlayer.pods - 1
        printBoard()
    }
    
    func hasEnoughPods(_ player: Player) -> Bool {
        return player.pods > 2
    }
    
    func endGame() -> Void {
        let winner = firstPlayer.pods > 3 ? firstPlayer.nickname : secondPlayer.nickname
        print("Game over")
        print(winner, " won!")
    }
    
}
