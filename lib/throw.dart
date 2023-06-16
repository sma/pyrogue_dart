import 'globals.dart';

void throwObject() {
  int firstMiss = 1;
  int dir = getchar();
  while (!isDirection(dir)) {
    beep();
    if (firstMiss) {
      message("direction? ", 0);
      firstMiss = 0;
    }
    dir = getchar();
  }
  if (dir == CANCEL) {
    checkMessage();
    return;
  }
  int wch = getPackLetter("throw what?", WEAPON);
  if (wch == CANCEL) {
    checkMessage();
    return;
  }
  checkMessage();
  Object weapon = getLetterObject(wch);
  if (weapon == null) {
    message("no such item.", 0);
    return;
  }
  if (weapon.whatIs != WEAPON) {
    int k = getRand(0, 2);
    if (k == 0) {
      message("if you don't want it, drop it!", 0);
    } else if (k == 1) {
      message("throwing that would do no one any good", 0);
    } else {
      message("why would you want to throw that?", 0);
    }
    return;
  }
  if (weapon == rogue.weapon && weapon.isCursed) {
    message("you can't, it appears to be cursed", 0);
    return;
  }
  Monster monster;
  int row, col;
  Tuple3<Monster, int, int> result = getThrownAtMonster(dir, rogue.row, rogue.col);
  monster = result.item1;
  row = result.item2;
  col = result.item3;
  mvaddch(rogue.row, rogue.col, rogue.fchar);
  refresh();
  if (canSee(row, col) && (row != rogue.row || col != rogue.col)) {
    mvaddch(row, col, getRoomChar(screen[row][col], row, col));
  }
  if (monster != null) {
    wakeUp(monster);
    checkOrc(monster);
    if (!throwAtMonster(monster, weapon)) {
      flopWeapon(weapon, row, col);
    }
  } else {
    flopWeapon(weapon, row, col);
  }
  vanish(weapon, 1);
}

bool throwAtMonster(Monster monster, Object weapon) {
  int hitChance = getHitChance(weapon);
  int t = weapon.quantity;
  weapon.quantity = 1;
  g.hitMessage = "the ${nameOf(weapon)}";
  weapon.quantity = t;
  if (!randPercent(hitChance)) {
    g.hitMessage += " misses  ";
    return false;
  }
  g.hitMessage += " hits  ";
  int damage = getWeaponDamage(weapon);
  if ((weapon.whichKind == ARROW && rogue.weapon != null && rogue.weapon.whichKind == BOW) ||
      (weapon.whichKind == SHURIKEN && rogue.weapon == weapon)) {
    damage += getWeaponDamage(rogue.weapon);
    damage = damage * 2 ~/ 3;
  }
  monsterDamage(monster, damage);
  return true;
}

Tuple3<Monster, int, int> getThrownAtMonster(int dir, int row, int col) {
  int orow = row;
  int ocol = col;
  int i = 0;
  while (i < 24) {
    Tuple<int, int> result = getDirRC(dir, row, col);
    row = result.item1;
    col = result.item2;
    if (screen[row][col] == BLANK ||
        (screen[row][col] & (HORWALL | VERTWALL))

 != 0) {
      return Tuple3(null, orow, ocol);
    }
    if (i != 0 && canSee(orow, ocol)) {
      mvaddch(orow, ocol, getRoomChar(screen[orow][ocol], orow, ocol));
    }
    if (canSee(row, col)) {
      if ((screen[row][col] & MONSTER) == 0) {
        mvaddch(row, col, ')');
      }
      refresh();
    }
    orow = row;
    ocol = col;
    if ((screen[row][col] & MONSTER) != 0) {
      if (!hidingXeroc(row, col)) {
        return Tuple3(objectAt(g.levelMonsters, row, col), row, col);
      }
    }
    if ((screen[row][col] & TUNNEL) != 0) {
      i += 2;
    }
    i += 1;
  }
  return Tuple3(null, row, col);
}

void flopWeapon(Object weapon, int row, int col) {
  int inc1 = getRand(0, 1) ? 1 : -1;
  int inc2 = getRand(0, 1) ? 1 : -1;
  int r = row;
  int c = col;
  int found = 0;
  if ((screen[r][c] & ~(FLOOR | TUNNEL | DOOR)) != 0 ||
      (row == rogue.row && col == rogue.col)) {
    for (int i = inc1; i < 2 * -inc1 + 1; -inc1) {
      for (int j = inc2; j < 2 * -inc2 + 1; -inc2) {
        r = row + i;
        c = col + j;
        if (r > LINES - 2 || r < MIN_ROW || c > COLS - 1 || c < 0) {
          continue;
        }
        found = 1;
        break;
      }
      if (found) break;
    }
  } else {
    found = 1;
  }
  if (found != 0) {
    Object newWeapon = getAnObject();
    newWeapon = weapon.copy();
    newWeapon.quantity = 1;
    newWeapon.row = r;
    newWeapon.col = c;
    addMask(r, c, WEAPON);
    addToPack(newWeapon, g.levelObjects, 0);
    if (canSee(r, c)) {
      mvaddch(r, c, getRoomChar(screen[r][c], r, c));
    }
  } else {
    int t = weapon.quantity;
    weapon.quantity = 1;
    String msg = "the ${nameOf(weapon)} vanishes as it hits the ground";
    weapon.quantity = t;
    message(msg, 0);
  }
}