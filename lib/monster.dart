import 'globals.dart';

void putMonsters() {
  var n = getRand(3, 7);

  for (var i = 0; i < n; i++) {
    var monster = getRandomMonster();
    if ((monster.mFlags & WANDERS) != 0 && randPercent(50)) {
      wakeUp(monster);
    }
    putMonsterRandomLocation(monster);
    addToPack(monster, g.levelMonsters, false);
  }
}

Monster getRandomMonster() {
  var monster = getAnObject();
  int mn;
  while (true) {
    mn = getRand(0, MAXMONSTER - 1);
    if (g.currentLevel >= monsterTab[mn].isProtected &&
        g.currentLevel <= monsterTab[mn].isCursed) {
      break;
    }
  }
  monster = monsterTab[mn].copy();
  monster.whatIs = MONSTER;
  if (monster.ichar == 'X') {
    monster.identified = getRandomObjChar().codeUnitAt(0);
  }
  if (g.currentLevel > AMULET_LEVEL + 2) {
    monster.mFlags |= HASTED;
  }
  monster.trow = -1;
  return monster;
}

void moveMonsters() {
  var monster = g.levelMonsters.nextObject;

  while (monster != null) {
    if (monster.mFlags & HASTED != 0) {
      mvMonster(monster, rogue.row, rogue.col);
    } else if (monster.mFlags & SLOWED != 0) {
      monster.quiver = 1 - monster.quiver;
      if (monster.quiver != 0) {
        monster = monster.nextObject;
        continue;
      }
    }
    var flew = false;
    if (monster.mFlags & FLIES != 0 && !monsterCanGo(monster, rogue.row, rogue.col)) {
      flew = true;
      mvMonster(monster, rogue.row, rogue.col);
    }
    if (!flew || !monsterCanGo(monster, rogue.row, rogue.col)) {
      mvMonster(monster, rogue.row, rogue.col);
    }
    monster = monster.nextObject;
  }
}

void fillRoomWithMonsters(int rn, int n) {
  var r = rooms[rn];
  for (var i = 0; i < n + n ~/ 2; i++) {
    if (noRoomForMonster(rn)) break;
    int row;
    int col;
    while (true) {
      row = getRand(r.topRow + 1, r.bottomRow - 1);
      col = getRand(r.leftCol + 1, r.rightCol - 1);
      if ((screen[row][col] & MONSTER) == 0) break;
    }
    putMonsterAt(row, col, getRandomMonster());
  }
}

String getMonsterCharRowCol(int row, int col) {
  var monster = objectAt(g.levelMonsters, row, col)!;
  if ((!g.detectMonster && monster.mFlags & IS_INVIS != 0) || g.blind) {
    return getRoomChar(screen[row][col] & ~MONSTER, row, col);
  }
  if (monster.ichar == 'X' && monster.identified != 0) {
    return String.fromCharCode(monster.identified);
  }
  return monster.ichar;
}

String getMonsterChar(Monster monster) {
  if ((!g.detectMonster && monster.mFlags & IS_INVIS != 0) || g.blind) {
    return getRoomChar(screen[monster.row][monster.col] & ~MONSTER, monster.row, monster.col);
  }
  if (monster.ichar == 'X' && monster.identified != 0) {
    return String.fromCharCode(monster.identified);
  }
  return monster.ichar;
}

void mvMonster(Monster monster, int row, int col) {
  if (monster.mFlags & IS_ASLEEP != 0) {
    if ((monster.mFlags & WAKENS != 0) &&
        rogueIsAround(monster.row, monster.col) &&
        randPercent(WAKE_PERCENT)) {
      wakeUp(monster);
    }
    return;
  }

  if (monster.mFlags & FLITS != 0 && flit(monster)) {
    return;
  }

  if (monster.ichar == 'F' && !monsterCanGo(monster, rogue.row, rogue.col)) {
    return;
  }

  if (monster.ichar == 'I' && monster.identified == 0) {
    return;
  }

  if (monster.ichar == 'M' && !mConfuse(monster)) {
    return;
  }

  if (monsterCanGo(monster, rogue.row, rogue.col)) {
    monsterHit(monster, null);
    return;
  }

  if (monster.ichar == 'D' && flameBroil(monster)) {
    return;
  }

  if (monster.ichar == 'O' && orcGold(monster)) {
    return;
  }

  if (monster.trow == monster.row && monster.tcol == monster.col) {
    monster.trow = -1;
  } else if (monster.trow != -1) {
    row = monster.trow;
    col = monster.tcol;
  }

  if (monster.row > row) {
    row = monster.row - 1;
  } else if (monster.row < row) {
    row = monster.row + 1;
  }

  if (screen[row][monster.col] & DOOR != 0 && mTry(monster, row, monster.col)) {
    return;
  }

  if (monster.col > col) {
    col = monster.col - 1;
  } else if (monster.col < col) {
    col = monster.col + 1;
  }

  if (screen[monster.row][col] & DOOR != 0 && mTry(monster, monster.row, col)) {
    return;
  }

  if (mTry(monster, row, col)) {
    return;
  }

  final tried = List.filled(6, 0);
  for (var i = 0; i < 6; i++) {
    var n = getRand(0, 5);
    if (n == 0) {
      if (tried[n] == 0 && mTry(monster, row, monster.col - 1)) {
        return;
      }
    } else if (n == 1) {
      if (tried[n] == 0 && mTry(monster, row, monster.col)) {
        return;
      }
    } else if (n == 2) {
      if (tried[n] == 0 && mTry(monster, row, monster.col + 1)) {
        return;
      }
    } else if (n == 3) {
      if (tried[n] == 0 && mTry(monster, monster.row - 1, col)) {
        return;
      }
    } else if (n == 4) {
      if (tried[n] == 0 && mTry(monster, monster.row, col)) {
        return;
      }
    } else if (n == 5) {
      if (tried[n] == 0 && mTry(monster, monster.row + 1, col)) {
        return;
     

 }
    }
    tried[n] = 1;
  }
}

bool mTry(Monster monster, int row, int col) {
  if (monsterCanGo(monster, row, col)) {
    moveMonsterTo(monster, row, col);
    return true;
  }
  return false;
}

void moveMonsterTo(Monster monster, int row, int col) {
  addMask(row, col, MONSTER);
  removeMask(monster.row, monster.col, MONSTER);

  var c = mvinch(monster.row, monster.col);

  if ('A'.codeUnitAt(0) <= c.codeUnitAt(0) && c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
    mvaddch(monster.row, monster.col,
        getRoomChar(screen[monster.row][monster.col], monster.row, monster.col));
  }
  if (!g.blind && (g.detectMonster || canSee(row, col))) {
    if (!(monster.mFlags & IS_INVIS != 0) || g.detectMonster) {
      mvaddch(row, col, getMonsterChar(monster));
    }
  }
  if (screen[row][col] & DOOR != 0 &&
      getRoomNumber(row, col) != g.currentRoom &&
      screen[monster.row][monster.col] == FLOOR) {
    if (!g.blind) {
      mvaddch(monster.row, monster.col, ' ');
    }
  }
  if (screen[row][col] & DOOR != 0) {
    doorCourse(monster, (screen[monster.row][monster.col] & TUNNEL) != 0, row, col);
  } else {
    monster.row = row;
    monster.col = col;
  }
}

bool monsterCanGo(Monster monster, int row, int col) {
  var dr = monster.row - row;
  if (dr <= -2 || dr >= 2) return false;
  var dc = monster.col - col;
  if (dc <= -2 || dc >= 2) return false;

  if (screen[monster.row][col] == 0 || screen[row][monster.col] == 0) {
    return false;
  }
  if (!isPassable(row, col) || screen[row][col] & MONSTER != 0) {
    return false;
  }
  if (monster.row != row &&
      monster.col != col &&
      (screen[row][col] & DOOR != 0 || screen[monster.row][monster.col] & DOOR != 0)) {
    return false;
  }
  if (!(monster.mFlags & FLITS != 0) &&
      !(monster.mFlags & CAN_GO != 0) &&
      monster.trow == -1) {
    if (monster.row < rogue.row && row < monster.row) return false;
    if (monster.row > rogue.row && row > monster.row) return false;
    if (monster.col < rogue.col && col < monster.col) return false;
    if (monster.col > rogue.col && col > monster.col) return false;
  }

  if (screen[row][col] & SCROLL != 0) {
    var obj = objectAt(g.levelObjects, row, col);
    if (obj!.whichKind == SCARE_MONSTER) {
      return false;
    }
  }

  return true;
}

void wakeUp(Monster monster) {
  monster.mFlags &= ~IS_ASLEEP;
}

void wakeRoom(int rn, bool entering, int row, int col) {
  var wakePercent = rn == g.partyRoom ? PARTY_WAKE_PERCENT : WAKE_PERCENT;

  var monster = g

.levelMonsters.nextObject;
  while (monster != null) {
    if ((monster.mFlags & WAKENS != 0 || rn == g.partyRoom) &&
        rn == getRoomNumber(monster.row, monster.col)) {
      if (monster.ichar == 'X' && rn == g.partyRoom) {
        monster.mFlags |= WAKENS;
      }
      if (entering) {
        monster.trow = -1;
      } else {
        monster.trow = row;
        monster.tcol = col;
      }
      if (randPercent(wakePercent) && monster.mFlags & WAKENS != 0) {
        if (monster.ichar != 'X') {
          wakeUp(monster);
        }
      }
    }
    monster = monster.nextObject;
  }
}

String monsterName(Monster monster) {
  if (g.blind || (monster.mFlags & IS_INVIS != 0 && !g.detectMonster)) {
    return "something";
  }
  if (g.halluc) {
    return monsterNames[getRand(0, 25)];
  }
  return monsterNames[monster.ichar.codeUnitAt(0) - 'A'.codeUnitAt(0)];
}

bool rogueIsAround(int row, int col) {
  var rdif = (row - rogue.row).abs();
  var cdif = (col - rogue.col).abs();
  return rdif < 2 && cdif < 2;
}

void startWanderer() {
  Object monster;
  while (true) {
    monster = getRandomMonster();
    if ((monster.mFlags & WAKENS != 0) || (monster.mFlags & WANDERS != 0)) break;
  }
  wakeUp(monster);
  for (var i = 0; i < 12; i++) {
    var (row, col) = getRandRowCol(FLOOR | TUNNEL | IS_OBJECT);
    if (!canSee(row, col)) {
      putMonsterAt(row, col, monster);
      return;
    }
  }
}

void showMonsters() {
  if (g.blind) return;

  var monster = g.levelMonsters.nextObject;
  while (monster != null) {
    mvaddch(monster.row, monster.col, monster.ichar);
    if (monster.ichar == 'X') {
      monster.identified = 0;
    }
    monster = monster.nextObject;
  }
}

void createMonster() {
  var inc1 = getRand(0, 1) == 1 ? 1 : -1;
  var inc2 = getRand(0, 1) == 1 ? 1 : -1;

  var found = false;
  for (var i = inc1; i < 2 * -inc1; i -= inc1) {
    late int row;
    late int col;
    for (var j = inc2; j < 2 * -inc2; j -= inc2) {
      if (i == 0 && j == 0) continue;
      row = rogue.row + i;
      col = rogue.col + j;
      if (row < MIN_ROW ||
          row > LINES - 2 ||
          col < 0 ||
          col > COLS - 1) {
        continue;
      }
      if ((screen[row][col] & MONSTER) == 0 &&
          (screen[row][col] & (FLOOR | TUNNEL | STAIRS)) != 0) {
        found = true;
        break;
      }
    }
    if (found) {
      var monster = getRandomMonster();
      putMonsterAt(row, col, monster);
      mvaddch(row, col, getMonsterChar(monster));
      if ((monster.mFlags & WANDERS != 0)) {
        wakeUp(monster);
      }
    } else {
      message("you hear a faint cry of anguish in the distance", 0);
    }
  }
}

void putMonsterAt(int row, int col, Monster monster) {
  monster.row = row;
  monster.col = col;
  addMask(row, col, MONSTER);
  addToPack(monster, g.levelMonsters, false);
}

bool canSee(int row, int col) {
  return !g.blind &&
      (getRoomNumber(row, col) == g.currentRoom || rogueIsAround(row, col));
}

bool flit(Monster monster) {
  if (!randPercent(FLIT_PERCENT)) {
    return false;
  }
  var inc1 = getRand(0, 1) == 1 ? 1 : -1;
  var inc2 = getRand(0, 1) == 1 ? 1 : -1;

  if (randPercent(10)) {
    return true;
  }

  for (var i = inc1; i < 2 * -inc1; i -= inc1) {
    for (var j = inc2; j < 2 * -inc2; j -= inc2) {
      var row = monster.row + i;
      var col = monster.col + j;
      if (row == rogue.row && col == rogue.col) {
        continue;
      }
      if (mTry(monster, row, col)) {
        return true;
      }
    }
  }
  return true;
}

void putMonsterRandomLocation(Monster monster) {
  var (row, col) = getRandRowCol(FLOOR | TUNNEL | IS_OBJECT);
  addMask(row, col, MONSTER);
  monster.row = row;
  monster.col = col;
}

String getRandomObjChar() {
  return "%!?]/):*"[getRand(0, 7)];
}

bool noRoomForMonster(int rn) {
  var r = rooms[rn];
  for (var i = r.leftCol + 1; i < r.rightCol; i++) {
    for (var j = r.topRow + 1; j < r.bottomRow; j++) {
      if ((screen[j][i] & MONSTER) == 0) {
        return false;
      }
    }
  }
  return true;
}

void aggravate() {
  message("you hear a high pitched humming noise");
  var monster = g.levelMonsters.nextObject;
  while (monster != null) {
    wakeUp(monster);
    if (monster.ichar == 'X') {
      monster.identified = 0;
    }
    monster = monster.nextObject;
  }
}

bool monsterCanSee(Monster monster, int row, int col) {
  var rn = getRoomNumber(row, col);

  if (rn != NO_ROOM && rn == getRoomNumber(monster.row, monster.col)) {
    return true;
  }

  return (row - monster.row).abs() < 2 && (col - monster.col).abs() < 2;
}

void mvAquatars() {
  var monster = g.levelMonsters.nextObject;
  while (monster != null) {
    if (monster.ichar == 'A') {
      mvMonster(monster, rogue.row, rogue.col);
    }
    monster = monster.nextObject;
  }
}

void doorCourse(Monster monster, bool entering, int row, int col) {
  monster.row = row;
  monster.col = col;

  if (monsterCanSee(monster, rogue.row, rogue.col)) {
    monster.trow = -1;
    return;
  }

  var rn = getRoomNumber(row, col);

  if (entering) {
    for (var i = 0; i < MAXROOMS; i++) {
      if (!rooms[i].isRoom || i == rn) continue;
      for (var j = 0; j < 4; j++) {
        var d = rooms[i].doors[j];
        if (d.otherRoom == rn) {
          monster.trow = d.otherRow;
          monster.tcol = d.otherCol;
          if (monster.trow == row && monster.tcol == col) {
            continue;
          }
          return;
        }
      }
    }
  } else {
    var (flag, r, c) = getOtherRoom(rn, row, col);
    if (flag) {
      monster.trow = r;
      monster.tcol = c;
    } else {
      monster.trow = -1;
    }
  }
}

(bool, int, int) getOtherRoom(int rn, int row, int col) {
  var d = -1;
  if (screen[row][col - 1] & HORWALL != 0 &&
      screen[row][col + 1] & HORWALL != 0) {
    if (screen[row + 1][col] & FLOOR != 0) {
      d = UP ~/ 2;
    } else {
      d = DOWN ~/ 2;
    }
  } else {
    if (screen[row][col + 1] & FLOOR != 0) {
      d = LEFT ~/ 2;
    } else {
      d = RIGHT ~/ 2;
    }
  }
  if (d != -1 && rooms[rn].doors[d].otherRoom > 0) {
    return (true, rooms[rn].doors[d].otherRow, rooms[rn].doors[d].otherCol);
  }
  return (false, 0, 0);
}