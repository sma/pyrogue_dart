import 'globals.dart';

void specialHit(Monster monster) {
  String k = monster.ichar;
  if (k == 'A') {
    rust(monster);
  } else if (k == 'F') {
    g.beingHeld = 1;
  } else if (k == 'I') {
    freeze(monster);
  } else if (k == 'L') {
    stealGold(monster);
  } else if (k == 'N') {
    stealItem(monster);
  } else if (k == 'R') {
    sting(monster);
  } else if (k == 'V') {
    drainLife();
  } else if (k == 'W') {
    drainLevel();
  }
}

void rust(Monster monster) {
  if (rogue.armor == null ||
      getArmorClass(rogue.armor) <= 1 ||
      rogue.armor.whichKind == LEATHER) {
    return;
  }
  if (rogue.armor.isProtected) {
    if (!monster.identified) {
      message("the rust vanishes instantly", 0);
      monster.identified = 1;
    }
  } else {
    rogue.armor.damageEnchantment -= 1;
    message("your armor weakens", 0);
    printStats();
  }
}

void freeze(Monster monster) {
  if (randPercent(12)) return;

  double freezePercent = 99;
  freezePercent -= rogue.strengthCurrent + rogue.strengthCurrent / 2;
  freezePercent -= rogue.exp * 4;
  freezePercent -= getArmorClass(rogue.armor) * 5;
  freezePercent -= rogue.hpMax / 3;

  if (freezePercent > 10) {
    monster.identified = 1;
    message("you are frozen", 1);

    int n = getRand(5, 9);
    for (int i = 0; i < n; i++) {
      moveMonsters();
    }
    if (randPercent(freezePercent)) {
      for (int i = 0; i < 50; i++) {
        moveMonsters();
      }
      killedBy(null, HYPOTHERMIA);
    }
    message("you can move again", 1);
    monster.identified = 0;
  }
}

void stealGold(Monster monster) {
  if (randPercent(15)) return;

  if (rogue.gold > 50) {
    double amount = rogue.gold > 1000
        ? getRand(8, 15)
        : getRand(2, 5);
    amount = rogue.gold / amount;
    amount += (getRand(0, 2) - 1) * (rogue.exp + g.currentLevel);
    if (amount <= 0 && rogue.gold > 0) {
      amount = rogue.gold;
    }
    if (amount > 0) {
      rogue.gold -= amount;
      message("your purse feels lighter", 0);
      printStats();
    }
  }
  disappear(monster);
}

void stealItem(Monster monster) {
  if (randPercent(15)) return;

  bool hasSomething = false;
  Object obj = rogue.pack.nextObject;
  while (obj != null) {
    if (obj != rogue.armor && obj != rogue.weapon) {
      hasSomething = true;
      break;
    }
    obj = obj.nextObject;
  }
  if (hasSomething) {
    int n = getRand(0, MAX_PACK_COUNT);
    obj = rogue.pack.nextObject;
    for (int i = 0; i < n + 1;

 i++) {
      obj = obj.nextObject;
      while (obj == null || obj == rogue.armor || obj == rogue.armor) {
        if (obj == null) {
          obj = rogue.pack.nextObject;
        } else {
          obj = obj.nextObject;
        }
      }
    }
    message("she stole ${getDescription(obj)}", 0);
    if (obj.whatIs == AMULET) {
      g.hasAmulet = 0;
    }
    vanish(obj, 0);
  }
  disappear(monster);
}

void disappear(Monster monster) {
  int row = monster.row;
  int col = monster.col;

  removeMask(row, col, MONSTER);
  if (canSee(row, col)) {
    mvaddch(row, col, getRoomChar(screen[row][col], row, col));
  }
  removeFromPack(monster, g.levelMonsters);
}

void coughUp(Monster monster) {
  if (g.currentLevel < g.maxLevel) return;

  if (monster.ichar == 'L') {
    Object obj = getAnObject();
    obj.whatIs = GOLD;
    obj.quantity = getRand(9, 599);
  } else {
    if (randPercent(monster.whichKind)) {
      Object obj = getRandObject();
    } else {
      return;
    }
  }

  int row = monster.row;
  int col = monster.col;

  for (int n = 0; n < 6; n++) {
    for (int i = -n; i < n + 1; i++) {
      if (tryToCough(row + n, col + i, obj)) return;
      if (tryToCough(row - n, col + i, obj)) return;
    }
    for (int i = -n; i < n + 1; i++) {
      if (tryToCough(row + i, col - n, obj)) return;
      if (tryToCough(row + i, col + n, obj)) return;
    }
  }
}

bool tryToCough(int row, int col, Object obj) {
  if (row < MIN_ROW ||
      row > LINES - 2 ||
      col < 0 ||
      col > COLS - 1) {
    return false;
  }
  if ((screen[row][col] & IS_OBJECT) == 0 &&
      (screen[row][col] & MONSTER) == 0 &&
      (screen[row][col] & (TUNNEL | FLOOR | DOOR)) != 0) {
    putObjectAt(obj, row, col);
    mvaddch(row, col, getRoomChar(screen[row][col], row, col));
    refresh();
    return true;
  }
  return false;
}

bool orcGold(Monster monster) {
  if (monster.identified) {
    return false;
  }
  int rn = getRoomNumber(monster.row, monster.col);
  if (rn < 0) {
    return false;
  }
  Room r = rooms[rn];
  for (int i = r.topRow + 1; i < r.bottomRow; i++) {
    for (int j = r.leftCol + 1; j < r.rightCol; j++) {
      if ((screen[i][j] & GOLD) != 0 && (screen[i][j] & MONSTER) == 0) {
        monster.mFlags |= CAN_GO;
        bool s = monsterCanGo(monster, i, j);
        monster.mFlags &= ~CAN_GO;
        if (s) {
          moveMonsterTo(monster,

 i, j);
          monster.mFlags |= IS_ASLEEP;
          monster.mFlags &= ~WAKENS;
          monster.identified = 1;
          return true;
        }
        monster.identified = 1;
        monster.mFlags |= CAN_GO;
        mvMonster(monster, i, j);
        monster.mFlags &= ~CAN_GO;
        monster.identified = 0;
        return true;
      }
    }
  }
  return false;
}

void checkOrc(Monster monster) {
  if (monster.ichar == 'O') {
    monster.identified = 1;
  }
}

bool checkXeroc(Monster monster) {
  if (monster.ichar == 'X' && monster.identified) {
    wakeUp(monster);
    monster.identified = 0;
    mvaddch(
        monster.row, monster.col, getRoomChar(screen[monster.row][monster.col],
        monster.row, monster.col));
    checkMessage();
    message("wait, that's a ${monsterName(monster)}!", 1);
    return true;
  }
  return false;
}

bool hidingXeroc(int row, int col) {
  if (g.currentLevel < XEROC1 || g.currentLevel > XEROC2 ||
      (screen[row][col] & MONSTER) == 0) {
    return false;
  }

  Monster monster = objectAt(g.levelMonsters, row, col);
  return monster.ichar == 'X' && monster.identified;
}

void sting(Monster monster) {
  if (rogue.strengthCurrent < 5) return;

  int stingChance = 35;
  int ac = getArmorClass(rogue.armor);
  stingChance += 6 * (6 - ac);

  if (rogue.exp > 8) {
    stingChance -= 6 * (rogue.exp - 8);
  }

  stingChance = min(max(stingChance, 1), 100);

  if (randPercent(stingChance)) {
    message("the ${monsterName(monster)}'s bite has weakened you", 0);
    rogue.strengthCurrent -= 1;
    printStats();
  }
}

void drainLevel() {
  if (!randPercent(20) || rogue.exp < 8) {
    return;
  }

  rogue.expPoints = levelPoints[rogue.exp - 2] - getRand(10, 50);
  rogue.exp -= 2;
  addExp(1);
}

void drainLife() {
  if (!randPercent(25) || rogue.hpMax <= 30 || rogue.hpCurrent < 10) {
    return;
  }
  message("you feel weaker", 0);
  rogue.hpMax -= 1;
  rogue.hpCurrent -= 1;
  if (randPercent(50)) {
    if (rogue.strengthCurrent >= 5) {
      rogue.strengthCurrent -= 1;
      if (randPercent(50)) {
        rogue.strengthMax -= 1;
      }
    }
  }
  printStats();
}

bool mConfuse(Monster monster) {
  if (monster.identified) {
    return false;
  }
  if (!canSee(monster.row, monster.col)) {
    return false;
  }
  if (randPercent(45)) {
    monster.identified = 1;
    return false;
  }
  if (randPercent(55)) {
    monster.identified = 1;
    message("the gaze of the ${monsterName(monster)} has confused you", 1);
    confuse();
    return true;
  }
  return false;
}

bool flameBroil(Monster monster) {
  if (randPercent(50)) {
    return false;
  }
  int row = monster.row;
  int col = monster.col;
  if (!canSee(row, col)) {
    return false;
  }
  if (!rogueIsAround(row, col)) {
    row = rogue.row;
    col = rogue.col;
    standout();
    while (true) {
      mvaddch(row, col, '*');
      refresh();
      row = getCloser(row, col, rogue.row, rogue.col);
      if (row == rogue.row && col == rogue.col) break;
    }
    standend();
    row = getCloser(monster.row, monster.col, rogue.row, rogue.col);
    while (true) {
      mvaddch(row, col, getRoomChar(screen[row][col], row, col));
      refresh();
      row = getCloser(row, col, rogue.row, rogue.col);
      if (row == rogue.row && col == rogue.col) break;
    }
  }
  monsterHit(monster, "flame");
  return true;
}

Tuple<int, int> getCloser(int row, int col, int trow, int tcol) {
  if (row < trow) {
    row += 1;
  } else if (row > trow) {
    row -= 1;
  }
  if (col < tcol) {
    col += 1;
  } else if (col > tcol) {
    col -= 1;
  }
  return Tuple(row, col);
}