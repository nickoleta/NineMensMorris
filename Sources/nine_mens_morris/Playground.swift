class Playground {
    
    let INITIAL_MOVES_COUNT = 1
    let FREE_POSITION : Character = "o"
    
    let GAME_NAME = "Nine men's morris"
    let INVALID_MOVE_MSG = "Invalid move!"
    
    private(set) var firstPlayer: Player
    private(set) var secondPlayer: Player
    private(set) var game: Game
    
    init(firstPlayer: Player, secondPlayer: Player){
        self.firstPlayer = firstPlayer
        self.secondPlayer = secondPlayer
        self.game = Game()
    }
    
    public func startGame() {
        print(GAME_NAME)
        
        printBoard()
        
        // Each player has 9 initial moves
        var initialMoves = INITIAL_MOVES_COUNT
        while initialMoves > 0 {
            move(true, firstPlayer, secondPlayer)
            move(true, secondPlayer, firstPlayer)
            initialMoves = initialMoves - 1
            print("Initial moves: \(initialMoves)")
        }
        
        repeat {
            move(false, firstPlayer, secondPlayer)
            if !hasEnoughPawns(secondPlayer) {
                endGame()
                return
            }
            move(false, secondPlayer, firstPlayer)
        } while hasEnoughPawns(firstPlayer)
        
        endGame()
    }
    
    public func endGame() {
        let winner = firstPlayer.pawns > 3 ? firstPlayer.nickname : secondPlayer.nickname
        print("Game over! \(winner) won!")
    }
    
    private func move(_ isInitialMove: Bool, _ player: Player, _ enemy: Player) {
        var coordinates: [Character]
        
        repeat {
            print("Player \(player.nickname)")
                
            let input = readLine()
            coordinates = Array(input!)
        } while !isValidInput(coordinates, isInitialMove, player, enemy) || !isValidMove(coordinates,isInitialMove, player, enemy)
        
        
        makeMove(isInitialMove, coordinates, player, enemy)
    }
    
    private func makeMove(_ isInitialMove: Bool, _ coordinates: [Character], _ player: Player, _ enemy: Player) {
        let xCoordinate: Int
        let yCoordinate: Int
        
        if isInitialMove {
            xCoordinate = getX(coordinates[0])
            yCoordinate = Int(String(coordinates[1]))! - 1 // starts counting from 0
        }else{
            let oldXCoordinate = getX(coordinates[0])
            let oldYCoordinate = Int(String(coordinates[1]))! - 1
            
            game.board[oldXCoordinate][oldYCoordinate] = FREE_POSITION
            
            xCoordinate = getX(coordinates[2])
            yCoordinate = Int(String(coordinates[3]))! - 1
        }
        
        let firstPlayerNickname = player.nickname
        game.board[xCoordinate][yCoordinate] = firstPlayerNickname
        printBoard()
        
        if hasThreePawns(xCoordinate, yCoordinate, firstPlayerNickname) {
            removePawn(player, enemy, isInitialMove)
            printBoard()
        }
    }
    
    private func isValidInput(_ coordinates: [Character], _ isInitialMove: Bool, _ player: Player, _ enemy: Player) -> Bool {
        let xCoordinate = getX(coordinates[0])
        let yCoordinateStr = coordinates[1]
        if yCoordinateStr <= "0" || yCoordinateStr > "9" {
            print(INVALID_MOVE_MSG)
            return false
        }
        let yCoordinate = Int(String(yCoordinateStr))! - 1
        
        // verify boundaries
        let boardSize = game.board.count
        if xCoordinate >= boardSize || xCoordinate < 0 || yCoordinate >= boardSize || yCoordinate < 0 {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        // verify that the chosen position is legal
        let value = game.board[xCoordinate][yCoordinate]
        if value == "X" || value == "|" || value == "-" {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        return true
    }
    
    private func isValidMove(_ coordinates: [Character], _ isInitialMove: Bool, _ player: Player, _ enemy: Player) -> Bool {
        if isInitialMove && coordinates.count != 2 {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        if !isInitialMove && coordinates.count != 4 {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        let oldXCoordinate = getX(coordinates[0])
        let oldYCoordinate = Int(String(coordinates[1]))! - 1
        
        if isInitialMove {
            let value = game.board[oldXCoordinate][oldYCoordinate]
            return value != player.nickname && value != enemy.nickname
        }
        
        let newXCoordinate = getX(coordinates[2])
        let newYCoordinate = Int(String(coordinates[3]))! - 1
        
        let oldPositionValue = game.board[oldXCoordinate][oldYCoordinate]
        let newPositionValue = game.board[newXCoordinate][newYCoordinate]
        
        if oldPositionValue != player.nickname {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        if newPositionValue != FREE_POSITION {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        if oldXCoordinate != newXCoordinate && oldYCoordinate != newYCoordinate {
            print(INVALID_MOVE_MSG)
            return false
        }
        
        if oldXCoordinate == newXCoordinate {
            return areTwoPositionsNextToEachOther(oldXCoordinate, oldYCoordinate, newYCoordinate)
        } else {
            return areTwoPositionsNextToEachOther(oldYCoordinate, oldXCoordinate, newXCoordinate)
        }
    }
    
    private func areTwoPositionsNextToEachOther(_ staticCoordinate: Int, _ oldCoordinate: Int, _ newCoordinate: Int) -> Bool {
        let maxDistance = getPossitionsDistnace(staticCoordinate)
        if oldCoordinate - newCoordinate != maxDistance && newCoordinate - oldCoordinate != maxDistance {
            print(INVALID_MOVE_MSG)
            return false
        }
        return true
    }

    private func getX(_ xCoordinate: Character) -> Int {
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
            return 7
        }
    }
    
    private func hasThreePawns(_ xCoordinate: Int, _ yCoordinate: Int, _ playerNickname: Character) -> Bool {
        // middle rows are handled differently
        if xCoordinate == 3 || yCoordinate == 3 {
            return checkAllPossibilities(xCoordinate, yCoordinate, [], playerNickname, true)
        }
        
        let possibilities = getPossibilities(xCoordinate) // TODO: should be xcoodrinate/yCoordinate ?
        return checkAllPossibilities(xCoordinate, yCoordinate, possibilities, playerNickname, false)
    }
    
    private func checkAllPossibilities(_ xCoordinate: Int, _ yCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character, _ isMiddleRow: Bool) -> Bool {
        if isMiddleRow {
            return checkAllPossibilitiesForMiddleRow(xCoordinate, yCoordinate, playerNickname)
        }
        return checkHorizontally(xCoordinate, possibilities, playerNickname) || checkVertically(yCoordinate, possibilities, playerNickname)
    }
    
    private func checkAllPossibilitiesForMiddleRow(_ xCoordinate: Int, _ yCoordinate: Int, _ playerNickname: Character) -> Bool {
        var hasThreePawnsHorizontally = false
        var hasThreePawnsVertically = false
        
        if xCoordinate == 3 {
            if yCoordinate < 3 {
                hasThreePawnsHorizontally = checkHorizontally(xCoordinate, [0,1,2], playerNickname)
            } else {
                hasThreePawnsHorizontally = checkHorizontally(xCoordinate, [4, 5, 6], playerNickname)
            }
            let possibilities = getPossibilities(yCoordinate)
            hasThreePawnsVertically = checkVertically(yCoordinate, possibilities, playerNickname)
        }
        
        if yCoordinate == 3 {
            if xCoordinate < 3 {
                hasThreePawnsVertically = checkVertically(yCoordinate, [0,1,2], playerNickname)
            } else {
                hasThreePawnsVertically = checkVertically(yCoordinate, [4, 5, 6], playerNickname)
            }
            let possibilities = getPossibilities(xCoordinate)
            hasThreePawnsHorizontally = checkHorizontally(xCoordinate, possibilities, playerNickname)
        }
        
        return hasThreePawnsHorizontally || hasThreePawnsVertically
    }

    private func checkVertically(_ yCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character) -> Bool{
        for possibility in possibilities {
            if game.board[possibility][yCoordinate] != playerNickname {
                return false
            }
        }
        return true
    }
    
    private func checkHorizontally(_ xCoordinate: Int, _ possibilities: [Int], _ playerNickname: Character) -> Bool {
        for possibility in possibilities {
            if game.board[xCoordinate][possibility] != playerNickname {
                return false
            }
        }
        return true
    }
    
    private func getPossibilities(_ coordinate: Int) -> [Int] {
        switch coordinate {
            case 0, 6:
                return [0, 3, 6]
            case 1, 5:
                return [1, 3, 5]
            case 2, 4:
                return [2, 3, 4]
            default:
                return []
        }
    }
    
    private func getPossitionsDistnace(_ coordinate: Int) -> Int {
        switch coordinate {
            case 0, 6:
                return 3
            case 1, 5:
                return 2
            case 2, 3, 4:
                return 1
            default:
                return 0
        }
    }
    
    private func printBoard() {
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
    
    private func removePawn(_ player: Player, _ enemy: Player, _ isInitialMove: Bool) {
        var coordinates: [Character]
        var xCoordinate: Int
        var yCoordinate: Int
        repeat {
            print("Please, choose a pawn to be removed")
            let input = readLine()
            coordinates = Array(input!)

            xCoordinate = getX(coordinates[0])
            yCoordinate = Int(String(coordinates[1]))! - 1
        } while !isValidInput(coordinates, isInitialMove, player, enemy) || game.board[xCoordinate][yCoordinate] != enemy.nickname || !canPawnBeRemoved(xCoordinate, yCoordinate, enemy)

        game.board[xCoordinate][yCoordinate] = FREE_POSITION
        
        if !hasEnoughPawns(enemy) {
            endGame()
            return
        }

        enemy.pawns = enemy.pawns - 1
        printBoard()
    }
    
    private func canPawnBeRemoved(_ xCoordinate: Int, _ yCoordinate : Int, _ player: Player) -> Bool {
        return !hasThreePawns(xCoordinate, yCoordinate, player.nickname)
    }
    
    private func hasEnoughPawns(_ player: Player) -> Bool {
        return player.pawns > 2
    }
    
}
