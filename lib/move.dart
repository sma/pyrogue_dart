import 'globals.dart';

int moves = 0;
int hExp = -1;
int hN = 0;
int hC = 0;

int singleMoveRogue(String dirch, bool pickup) {
  var row = rogue.row;
  var col = rogue.col;

  if (g.beingHeld) {
    (row, col) = getDirRc(dirch, row, col);

    if ((screen[row][col] & MONSTER) == 0) {
      message("you are being held", 1);
      return MOVE_FAILED;
    }
  }

  row = rogue.row;
  col = rogue.col;

  if (g.confused > 0) {
    dirch = String.fromCharCode(dirch.codeUnitAt(0) + 32);
  }

  (row, col) = getDirRc(dirch, row, col);

  if ((screen[row][col] & MONSTER) != 0) {
    rogueHit(objectAt(g.levelMonsters, row, col)!);
    registerMove();
    return MOVE_FAILED;
  }

  if (!canMove(rogue.row, rogue.col, row, col)) {
    return MOVE_FAILED;
  }

  if ((screen[row][col] & DOOR) != 0) {
    if (g.currentRoom == PASSAGE) {
      g.currentRoom = getRoomNumber(row, col);
      lightUpRoom();
      wakeRoom(g.currentRoom, true, row, col);
    } else {
      lightPassage(row, col);
    }
  } else if ((screen[rogue.row][rogue.col] & DOOR) != 0 && (screen[row][col] & TUNNEL) != 0) {
    lightPassage(row, col);
    wakeRoom(g.currentRoom, false, row, col);
    darkenRoom(g.currentRoom);
    g.currentRoom = PASSAGE;
  } else if ((screen[row][col] & TUNNEL) != 0) {
    lightPassage(row, col);
  }

  mvaddch(rogue.row, rogue.col, getRoomChar(screen[rogue.row][rogue.col], rogue.row, rogue.col));
  mvaddch(row, col, rogue.fchar);
  rogue.row = row;
  rogue.col = col;

  if ((screen[row][col] & CAN_PICK_UP) != 0) {
    Object? obj;
    if (pickup) {
      bool status;
      (obj, status) = pickUp(row, col);
      if (obj != null) {
        var description = getDescription(obj);
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
        return g.confused > 0 ? STOPPED_ON_SOMETHING : MOVED;
      } else {
        // MOVE_ON:
        obj = objectAt(g.levelObjects, row, col)!;
        var description = "moved onto ${getDescription(obj)}";
        // NOT_IN_PACK:
        message(description, 1);
        registerMove();
        return STOPPED_ON_SOMETHING;
      }
    } else {
      // MOVE_ON:
      obj = objectAt(g.levelObjects, row, col)!;
      var description = "moved onto ${getDescription(obj)}";
      // NOT_IN_PACK:
      message(description, 1);
      registerMove();
      return STOPPED_ON_SOMETHING;
    }

    var description = getDescription(obj);
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

  return g.confused > 0 ? STOPPED_ON_SOMETHING : MOVED;
}

void multipleMoveRogue(String dirch) {
  if (dirch.contains("\x08\x0A\x0B\x0C\x1F\x19\x10\x02")) {
    while (true) {
      var row = rogue.row;
      var col = rogue.col;
      var m = singleMoveRogue(String.fromCharCode(dirch.codeUnitAt(0) + 96), true);
      if (m == MOVE_FAILED || m == STOPPED_ON_SOMETHING || g.interrupted) {
        break;
      }
      if (nextToSomething(row, col)) {
        break;
      }
    }
  } else if (dirch.contains("HJKLBYUN")) {
    while (!g.interrupted && singleMoveRogue(String.fromCharCode(dirch.codeUnitAt(0) + 32), true) == MOVED) {
      // pass
    }
  }
}

bool isPassable(int row, int col) {
  if (row < MIN_ROW || row > LINES - 2 || col < 0 || col > COLS - 1) {
    return false;
  }
  return (screen[row][col] & (FLOOR | TUNNEL | DOOR | STAIRS)) != 0;
}

bool nextToSomething(int drow, int dcol) {
  var passCount = 0;

  if (g.confused > 0) {
    return true;
  }
  if (g.blind > 0) {
    return false;
  }

  var iEnd = rogue.row < LINES - 2 ? 1 : 0;
  var jEnd = rogue.col < COLS - 1 ? 1 : 0;

  for (var i = rogue.row > MIN_ROW ? -1 : 0; i < iEnd + 1; i++) {
    for (var j = rogue.col > 0 ? -1 : 0; j < jEnd + 1; j++) {
      if (i == 0 && j == 0) continue;
      var r = rogue.row + i;
      var c = rogue.col + j;
      if (r == drow && c == dcol) continue;
      if ((screen[r][c] & (MONSTER | IS_OBJECT)) != 0) {
        return true;
      }
      if ((i - j == 1 || i - j == -1) && (screen[r][c] & TUNNEL) != 0) {
        passCount += 1;
        if (passCount > 1) {
          return true;
        }
      }
      if ((screen[r][c] & DOOR) != 0 || isObject(r, c)) {
        if (i == 0 || j == 0) {
          return true;
        }
      }
    }
  }
  return false;
}

bool canMove(int row1, int col1, int row2, int col2) {
  if (!isPassable(row2, col2)) {
    return false;
  }
  if (row1 != row2 && col1 != col2) {
    if ((screen[row1][col1] & DOOR) != 0 || (screen[row2][col2] & DOOR) != 0) {
      return false;
    }
    if ((screen[row1][col2] == 0) || (screen[row2][col1] == 0)) {
      return false;
    }
  }
  return true;
}

bool isObject(int row, int col) {
  return (screen[row][col] & IS_OBJECT) != 0;
}

void moveOnto() {
  var firstMiss = true;

  var ch = getchar();
  while (!isDirection(ch)) {
    beep();
    if (firstMiss) {
      message("direction? ", 0);
      firstMiss = false;
    }
    ch = getchar();
  }
  checkMessage();
  if (ch != CANCEL) {
    singleMoveRogue(ch, false);
  }
}

bool isDirection(String c) {
  return "hjklbyun".contains(c) || c == CANCEL;
}

bool isPackLetter(String c) {
  return "abcdefghijklmnopqrstuvwxyz".contains(c) || c == CANCEL || c == LIST;
}

bool checkHunger() {
  var fainted = false;
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
    var n = getRand(0, FAINT - rogue.movesLeft);
    if (n > 0) {
      fainted = true;
      if (randPercent(40)) rogue.movesLeft += 1;
      message("you faint", 1);
      for (var i = 0; i < n; i++) {
        if (randPercent(50)) {
          moveMonsters();
        }
      }
      message("you can move again", 1);
    }
  }
  if (rogue.movesLeft <= STARVE) {
    killedBy(null, STARVATION);
  }
  rogue.movesLeft -= 1;
  return fainted;
}

bool registerMove() {
  bool fainted;
  if (rogue.movesLeft <= HUNGRY && !g.hasAmulet) {
    fainted = checkHunger();
  } else {
    fainted = false;
  }

  moveMonsters();

  moves += 1;
  if (moves >= 80) {
    moves = 0;
    startWanderer();
  }

  if (g.halluc > 0) {
    g.halluc -= 1;
    if (g.halluc == 0) {
      unhallucinate();
    } else {
      hallucinate();
    }
  }

  if (g.blind > 0) {
    g.blind -= 1;
    if (g.blind == 0) {
      unblind();
    }
  }

  if (g.confused > 0) {
    g.confused -= 1;
    if (g.confused == 0) {
      unconfuse();
    }
  }

  heal();

  return fainted;
}

void rest(int count) {
  for (var i = 0; i < count; i++) {
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
  if (rogue.exp != hExp) {
    hExp = rogue.exp;

    if (hExp == 1) {
      hN = 20;
    } else if (hExp == 2) {
      hN = 18;
    } else if (hExp == 3) {
      hN = 17;
    } else if (hExp == 4) {
      hN = 14;
    } else if (hExp == 5) {
      hN = 13;
    } else if (hExp == 6) {
      hN = 11;
    } else if (hExp == 7) {
      hN = 9;
    } else if (hExp == 8) {
      hN = 8;
    } else if (hExp == 9) {
      hN = 6;
    } else if (hExp == 10) {
      hN = 4;
    } else if (hExp == 11) {
      hN = 3;
    } else {
      hN = 2;
    }
  }

  if (rogue.hpCurrent == rogue.hpMax) {
    hC = 0;
    return;
  }
  hC += 1;
  if (hC >= hN) {
    hC = 0;
    rogue.hpCurrent += 1;
    if (rogue.hpCurrent < rogue.hpMax) {
      if (randPercent(50)) {
        rogue.hpCurrent += 1;
      }
    }
    printStats();
  }
}
