class SudokuSolver {

  static void solveBoard(List<List<int>> board) {
    List<List<List<int>>> boardPossibles = [[[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]],
                                            [[0], [0], [0], [0], [0], [0], [0], [0], [0]]];
    List<List<List<int>>> lastBoardPossiblesState = List.of(boardPossibles), boardPossiblesBackup;
    List<List<int>> boardBackup;
    bool triedGuessing = false;
    List<int> triedAt = [0, 0];
    List<int> possiblesCache = [0];

    while(!_isComplete(board)) {
      // Check for every possible number in every empty field
      for(int i = 0; i < board.length; i++) {
        for(int j = 0; j < board[i].length; j++) {
          if(board[i][j] == 0) {                              // Empty field
            List<int> possibles = _solve(board, boardPossibles, [i, j]);
            // if only one is possible, write it to the board
            board[i][j] = possibles.length == 1 ? possibles[0] : 0;
            boardPossibles[i][j] = possibles;
          }
        }
      }
      printBoard(board);

      // Eliminate possibles based on other possibles
      for(int i = 0; i < boardPossibles.length; i++) {
        for(int j = 0; j < boardPossibles[i].length; j++) {
          if(boardPossibles[i][j].length > 1) {               // Field with more than one possibilities
            List<int> possibles = _solve2(board, boardPossibles, [i, j]);
            // if only one is possible, write it to the board
            board[i][j] = possibles.length == 1 ? possibles[0] : 0;
            boardPossibles[i][j] = possibles;
          }
        }
      }
      printBoard(board);

      // Check if the board changed to last round
      if(boardPossibles == lastBoardPossiblesState) {
        print("No solution found");
        // Try guessing the number for the first field with two possibles
        if(!triedGuessing) {
          boardBackup = List.of(board);
          boardPossiblesBackup = List.of(boardPossibles);
          for(int i = 0; i < boardPossibles.length; i++) {
            loop:
            for(int j = 0; j < boardPossibles[i].length; j++) {
              if(boardPossibles[i][j].length == 2) {               // Field with 2 possibilities
                board[i][j] = boardPossibles[i][j][0];
                boardPossibles[i][j].removeAt(1);

                triedGuessing = true;
                triedAt = [i, j];
                break loop;
              }
            }
          }
        } else {
          print("Go Back");
          board = List.of(boardBackup);
          boardPossibles = List.of(boardPossiblesBackup);

          board[triedAt[0]][triedAt[1]] = boardPossibles[triedAt[0]][triedAt[1]][1];
          boardPossibles[triedAt[0]][triedAt[1]] = [boardPossibles[triedAt[0]][triedAt[1]][1]];

          triedGuessing = false;
        }
      }
    }
  }

  static List<int> _solve(List<List<int>> board, List<List<List<int>>> boardPossibles, pos) {
    List<int> possibles = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    for(int i in board[pos[0]]) {
      if (i != 0 && possibles.contains(i)) {
        possibles.remove(i);
      }
    }

    for(List<int> i in board) {
      int val = i[pos[1]];
      if (val != 0 && possibles.contains(val)) {
        possibles.remove(val);
      }
    }

    //find notPossible in 3x3 grid
    List<List<int>> smallGrid = _getSmallGrid(pos);
    //print("smallGrid: " + str(small_grid))
    for (List<int> i in smallGrid) {
      int val = board[i[0]][i[1]];
      if (val != 0 && possibles.contains(val)) {
        possibles.remove(val);
      }
    }

    return possibles;
  }

  static List<int> _solve2(List<List<int>> board, List<List<List<int>>> boardPossibles, pos) {
    List<int> possibles = boardPossibles[pos[0]][pos[1]], removeCandidates = [], cache = [];

    for(int i = 0; i < boardPossibles[pos[0]].length; i++) {
      List<int> val = boardPossibles[pos[0]][i];
      if (i != pos[1]) {
        for(int j in val) {
          if(possibles.contains(j) && !cache.contains(j))
            cache.add(j);
        }
      }
    }
    removeCandidates.addAll(cache);
    cache.clear();

    for(int i = 0; i < boardPossibles.length; i++) {
      List<int> val = boardPossibles[i][pos[1]];
      if(i != pos[0]) {
        for(int j in val) {
          if(possibles.contains(j) && !cache.contains(j))
            cache.add(j);
        }
      }
    }
    removeCandidates.addAll(cache);
    cache.clear();

    //find notPossible in 3x3 grid
    List<List<int>> smallGrid = _getSmallGrid(pos);
    //print("smallGrid: " + str(small_grid))
    for(int i = 0; i < smallGrid.length; i++) {
      List<int> val = boardPossibles[smallGrid[i][0]][smallGrid[i][1]];
      if(!(pos[0] == smallGrid[i][0] && pos[1] == smallGrid[i][1])) {
        for(int j in val) {
          if(possibles.contains(j) && !cache.contains(j))
            cache.add(j);
        }
      }
    }
    removeCandidates.addAll(cache);
    cache.clear();

    int last = 0;
    for(int i = 0; i < removeCandidates.length; i++) {
      if(last != removeCandidates[i] && removeCandidates.where((num) => num == removeCandidates[i]).length < 3) {
        possibles = [removeCandidates[i]];
      }
      last = removeCandidates[i];
    }

    return possibles;
  }
  ///
  /// count in array (checks if more than zero 1 are in the array)
  /// array.where((num) => num == 1).length > 0
  ///

  static List<List<int>> _getSmallGrid(List<int> pos) {
    // print("Get Small Grid from " + str(pos[0]) + ", " + str(pos[1]))
    if (2 >= pos[1] && pos[1] >= 0) {
      if (2 >= pos[0] && pos[0] >= 0)
        return [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]];
      if (5 >= pos[0] && pos[0] >= 3)
        return [[3, 0], [3, 1], [3, 2], [4, 0], [4, 1], [4, 2], [5, 0], [5, 1], [5, 2]];
      if (8 >= pos[0] && pos[0] >= 6)
        return [[6, 0], [6, 1], [6, 2], [7, 0], [7, 1], [7, 2], [8, 0], [8, 1], [8, 2]];
    } else if( 5 >= pos[1] && pos[1] >= 3) {
      if (2 >= pos[0] && pos[0] >= 0)
        return [[0, 3], [0, 4], [0, 5], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5]];
      if (5 >= pos[0] && pos[0] >= 3)
        return [[3, 3], [3, 4], [3, 5], [4, 3], [4, 4], [4, 5], [5, 3], [5, 4], [5, 5]];
      if (8 >= pos[0] && pos[0] >= 6)
        return [[6, 3], [6, 4], [6, 5], [7, 3], [7, 4], [7, 5], [8, 3], [8, 4], [8, 5]];
    } else if (8 >= pos[1] && pos[1] >= 6) {
      if (2 >= pos[0] && pos[0] >= 0)
        return [[0, 6], [0, 7], [0, 8], [1, 6], [1, 7], [1, 8], [2, 6], [2, 7], [2, 8]];
      if (5 >= pos[0] && pos[0] >= 3)
        return [[3, 6], [3, 7], [3, 8], [4, 6], [4, 7], [4, 8], [5, 6], [5, 7], [5, 8]];
      if (8 >= pos[0] && pos[0] >= 6)
        return [[6, 6], [6, 7], [6, 8], [7, 6], [7, 7], [7, 8], [8, 6], [8, 7], [8, 8]];
    }
  }

  static bool _isComplete(List<List<int>> board) {
    for(int i = 0; i < board.length; i++) {
      for(int j = 0; j < board[i].length; j++) {
        if(board[i][j] == 0)
          return false;
      }
    }
    return true;
  }

  static void printBoard(List<List<int>> board) {
    print("");
    for(int i = 0; i < board.length; i++) {
      String line = "";
      for(int j = 0; j < board[i].length; j++) {
        if(j == 5 || j == 2)
          line += board[i][j] == 0 ? "  | " : board[i][j].toString() + " | ";
        else
          line += board[i][j] == 0 ? "  " : board[i][j].toString() + " ";
      }
      print(line);
      if(i == 5 || i == 2)
        print("------+-------+------");
    }
  }

}