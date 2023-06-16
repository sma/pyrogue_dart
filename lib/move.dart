import 'globals.dart';

int moves = 0;
int h_exp = -1;
int h_n = 0;
int h_c = 0;

int singleMoveRogue(String dirch, bool pickup) {
  int row = rogue.row;
  int col = rogue.col;

  if (g.beingHeld) {
    List<int> rc = getDirRc(dirch, row, col);
    row = rc[0];
    col = rc[1];

    if ((screen[row][col] & MONSTER) == 0) {
      message("you are being held", 1);
      return MOVE_FAILED;
    }
  }

  row = rogue.row;
  col = rogue.col;

  if (g.confused) {
    dirch = String.fromCharCode(dirch.codeUnitAt(0) + 32);
  }

  List<int> rc = getDirRc(dirch, row, col);
  row = rc[0];
  col = rc[1];

  if ((screen[row][col] & MONSTER) != 0) {
    rogueHit(objectAt(g.levelMonsters, row, col));
    registerMove();
    return MOVE_FAILED;
  }

  if (canMove(rogue.row, rogue.col, row, col) == 0) {
    return MOVE_FAILED;
  }

  if ((screen[row][col] & DOOR) != 0) {
    if (g.currentRoom == PASSAGE) {
      g.currentRoom = getRoomNumber(row, col);
      lightUpRoom();
      wakeRoom(g.currentRoom, 1, row, col);
    } else {
      lightPassage(row, col);
    }
  } else if ((screen[rogue.row][rogue.col] & DOOR) != 0 &&
      (screen[row][col] & TUNNEL) != 0) {
    lightPassage(row, col);
    wakeRoom(g.currentRoom, 0, row, col);
    darkenRoom(g.currentRoom);
    g.currentRoom = PASSAGE;
  } else if ((screen[row][col] & TUNNEL) != 0) {
    lightPassage(row, col);
  }

  mvaddch(rogue.row, rogue.col,
      getRoomChar(screen[rogue.row][rogue.col], rogue.row, rogue.col));
  mvaddch(row, col, rogue.fchar);
  rogue.row = row;
  rogue.col = col;

  if ((screen[row][col] & CAN_PICK_UP) != 0) {
    if (pickup) {
      List<dynamic> objStatus = pickUp(row, col);
      dynamic obj = objStatus[0];
      bool status = objStatus[1];
      if (obj != null) {
        String description = getDescription(obj);
        if (obj.whatIs == GOLD) {
          // NOT_IN_PACK:
          message(description, 1);
          registerMove();
          return STOPPED_ON_SOMETHING;
        }
      } else if (!status) {
        // MVED:
        if (registerMove()) {
          // fainted from hunger
          return STOPPED_ON_SOMETHING;
        }
        return g.confused ? STOPPED_ON_SOMETHING : MOVED;
      } else {
        // MOVE_ON:
        obj = objectAt(g.levelObjects, row, col);
        String description = "moved onto " + getDescription(obj);
        // NOT_IN_PACK:
        message(description, 1);
        registerMove();
        return STOPPED_ON_SOMETHING;
      }
    } else {
      // MOVE_ON:
      dynamic obj = objectAt(g.levelObjects, row, col);
      String description = "moved

 onto " + getDescription(obj);
      // NOT_IN_PACK:
      message(description, 1);
      registerMove();
      return STOPPED_ON_SOMETHING;
    }

    String description = getDescription(obj);
    description += "(";
    description += obj.ichar;
    description += ")";

    // NOT_IN_PACK:
    message(description, 1);
    registerMove();
    return STOPPED_ON_SOMETHING;
  }

  if ((screen[row][col] & DOOR) != 0 || (screen[row][col] & STAIRS) != 0) {
    registerMove();
    return STOPPED_ON_SOMETHING;
  }

  // MVED:
  if (registerMove()) {
    // fainted from hunger
    return STOPPED_ON_SOMETHING;
  }

  return g.confused ? STOPPED_ON_SOMETHING : MOVED;
}

void multipleMoveRogue(String dirch) {
  if (dirch.contains("\b\012\013\014\031\025\016\002")) {
    while (true) {
      int row = rogue.row;
      int col = rogue.col;
      int m = singleMoveRogue(String.fromCharCode(dirch.codeUnitAt(0) + 96), 1);
      if (m == MOVE_FAILED ||
          m == STOPPED_ON_SOMETHING ||
          g.interrupted) {
        break;
      }
      if (nextToSomething(row, col)) {
        break;
      }
    }
  } else if (dirch.contains("HJKLBYUN")) {
    while (!g.interrupted &&
        singleMoveRogue(String.fromCharCode(dirch.codeUnitAt(0) + 32), 1) ==
            MOVED) {
      // pass
    }
  }
}

int isPassable(int row, int col) {
  if (row < MIN_ROW || row > LINES - 2 || col < 0 || col > COLS - 1) {
    return 0;
  }
  return screen[row][col] & (FLOOR | TUNNEL | DOOR | STAIRS);
}

int nextToSomething(int drow, int dcol) {
  int passCount = 0;

  if (g.confused) {
    return 1;
  }
  if (g.blind) {
    return 0;
  }

  int iEnd = rogue.row < LINES - 2 ? 1 : 0;
  int jEnd = rogue.col < COLS - 1 ? 1 : 0;

  for (int i = rogue.row > MIN_ROW ? -1 : 0; i < iEnd + 1; i++) {
    for (int j = rogue.col > 0 ? -1 : 0; j < jEnd + 1; j++) {
      if (i == 0 && j == 0) continue;
      int r = rogue.row + i;
      int c = rogue.col + j;
      if (r == drow && c == dcol) continue;
      if ((screen[r][c] & (MONSTER | IS_OBJECT)) != 0) {
        return 1;
      }
      if ((i - j == 1 || i - j == -1) && (screen[r][c] & TUNNEL) != 0) {
        passCount += 1;
        if (passCount > 1) {
          return 1;
        }
      }
      if ((screen[r][c] & DOOR) != 0 || isObject(r, c) != 0) {
        if (i == 0 || j == 

0) {
          return 1;
        }
      }
    }
  }
  return 0;
}

int canMove(int row1, int col1, int row2, int col2) {
  if (isPassable(row2, col2) == 0) {
    return 0;
  }
  if (row1 != row2 && col1 != col2) {
    if ((screen[row1][col1] & DOOR) != 0 ||
        (screen[row2][col2] & DOOR) != 0) {
      return 0;
    }
    if ((screen[row1][col2] == 0) || (screen[row2][col1] == 0)) {
      return 0;
    }
  }
  return 1;
}

int isObject(int row, int col) {
  return screen[row][col] & IS_OBJECT;
}

void moveOnto() {
  bool firstMiss = true;

  String ch = String.fromCharCode(getchar());
  while (isDirection(ch) == 0) {
    beep();
    if (firstMiss) {
      message("direction? ", 0);
      firstMiss = false;
    }
    ch = String.fromCharCode(getchar());
  }
  checkMessage();
  if (ch != CANCEL) {
    singleMoveRogue(ch, 0);
  }
}

bool isDirection(String c) {
  return "hjklbyun".contains(c) || c == CANCEL;
}

bool isPackLetter(String c) {
  return "abcdefghijklmnopqrstuvwxyz".contains(c) || c == CANCEL || c == LIST;
}

void checkHunger() {
  bool fainted = false;
  if (rogue.movesLeft == HUNGRY) {
    g.hungerStr = "hungry";
    message(g.hungerStr, 0);
    printStats();
  }
  if (rogue.movesLeft == WEAK) {
    g.hungerStr = "weak";
    message(g.hungerStr, 0);
    printStats();
  }
  if (rogue.movesLeft <= FAINT) {
    if (rogue.movesLeft == FAINT) {
      g.hungerStr = "faint";
      message(g.hungerStr, 1);
      printStats();
    }
    int n = getRand(0, FAINT - rogue.movesLeft);
    if (n > 0) {
      fainted = true;
      if (randPercent(40)) rogue.movesLeft += 1;
      message("you faint", 1);
      for (int i = 0; i < n; i++) {
        if (randPercent(50)) {
          moveMonsters();
        }
      }
      message("you can move again", 1);
    }
  }
  if (rogue.movesLeft <= STARVE) {
    killedBy(0, STARVATION);
  }
  rogue.movesLeft -= 1;
  return fainted;
}

void registerMove() {
  moves += 1;
  if (moves >= 80) {
    moves = 0;
    startWanderer();
  }

  if (rogue.exp != h_exp) {
    h_exp = rogue.exp;

    if (h_exp == 1) {
      h_n = 20;
    } else if (h_exp == 2) {
      h_n = 18;
    } else if (h_exp == 3) {
      h_n = 17;
    } else if (h_exp == 4) {
      h_n = 14;
    } else if (h_exp == 5) {
      h_n = 13;
   

 } else if (h_exp == 6) {
      h_n = 11;
    } else if (h_exp == 7) {
      h_n = 9;
    } else if (h_exp == 8) {
      h_n = 8;
    } else if (h_exp == 9) {
      h_n = 6;
    } else if (h_exp == 10) {
      h_n = 4;
    } else if (h_exp == 11) {
      h_n = 3;
    } else {
      h_n = 2;
    }
  }

  if (rogue.hpCurrent == rogue.hpMax) {
    h_c = 0;
    return;
  }
  h_c += 1;
  if (h_c >= h_n) {
    h_c = 0;
    rogue.hpCurrent += 1;
    if (rogue.hpCurrent < rogue.hpMax) {
      if (randPercent(50)) {
        rogue.hpCurrent += 1;
      }
    }
    printStats();
  }
}

void rest(int count) {
  for (int i = 0; i < count; i++) {
    if (g.interrupted) {
      break;
    }
    registerMove();
  }
}

String getRandDir() {
  return "hjklyubn"[getRand(0, 7)];
}

void heal() {
  if (rogue.exp != h_exp) {
    h_exp = rogue.exp;

    if (h_exp == 1) {
      h_n = 20;
    } else if (h_exp == 2) {
      h_n = 18;
    } else if (h_exp == 3) {
      h_n = 17;
    } else if (h_exp == 4) {
      h_n = 14;
    } else if (h_exp == 5) {
      h_n = 13;
    } else if (h_exp == 6) {
      h_n = 11;
    } else if (h_exp == 7) {
      h_n = 9;
    } else if (h_exp == 8) {
      h_n = 8;
    } else if (h_exp == 9) {
      h_n = 6;
    } else if (h_exp == 10) {
      h_n = 4;
    } else if (h_exp == 11) {
      h_n = 3;
    } else {
      h_n = 2;
    }
  }

  if (rogue.hpCurrent == rogue.hpMax) {
    h_c = 0;
    return;
  }
  h_c += 1;
  if (h_c >= h_n) {
    h_c = 0;
    rogue.hpCurrent += 1;
    if (rogue.hpCurrent < rogue.hpMax) {
      if (randPercent(50)) {
        rogue.hpCurrent += 1;
      }
    }
    printStats();
  }
}
