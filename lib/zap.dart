import 'globals.dart';

void zapp() {
  var firstMiss = true;
  var dir = getchar();
  while (!isDirection(dir)) {
    beep();
    if (firstMiss) {
      message("direction? ", 0);
      firstMiss = false;
    }
    dir = getchar();
  }
  if (dir == CANCEL) {
    checkMessage();
    return;
  }

  final wch = getPackLetter("zap with what? ", WAND);
  if (wch == CANCEL) {
    checkMessage();
    return;
  }
  final wand = getLetterObject(wch);
  if (wand == null) {
    message("no such item.", 0);
    return;
  }
  if (wand.whatIs != WAND) {
    message("you can't zap with that", 0);
    return;
  }
  if (wand.clasz <= 0) {
    message("nothing happens", 0);
    // goto RM
  } else {
    wand.clasz -= 1;

    final monster = getZappedMonster(dir, rogue.row, rogue.col);
    if (monster != null) {
      wakeUp(monster);
      zapMonster(monster, wand.whichKind);
    }
  }
  // RM:
  registerMove();
}

Monster? getZappedMonster(String dir, int row, int col) {
  while (true) {
    final (r, c) = getDirRc(dir, row, col);
    if ((row == r && col == c) || (screen[r][c] & (HORWALL | VERTWALL)) != 0 || screen[r][c] == BLANK) {
      return null;
    }
    if ((screen[r][c] & MONSTER) != 0 && !hidingXeroc(r, c)) {
      return objectAt(g.levelMonsters, r, c);
    }
    row = r;
    col = c;
  }
}

void zapMonster(Monster monster, int kind) {
  final row = monster.row;
  final col = monster.col;

  if (kind == SLOW_MONSTER) {
    if ((monster.mFlags & HASTED) != 0) {
      monster.mFlags &= ~HASTED;
    } else {
      monster.quiver = 0;
      monster.mFlags |= SLOWED;
    }
  } else if (kind == HASTE_MONSTER) {
    if ((monster.mFlags & SLOWED) != 0) {
      monster.mFlags &= ~SLOWED;
    } else {
      monster.mFlags |= HASTED;
    }
  } else if (kind == TELEPORT_AWAY) {
    teleportAway(monster);
  } else if (kind == KILL_MONSTER) {
    rogue.expPoints -= monster.killExp;
    monsterDamage(monster, monster.quantity);
  } else if (kind == INVISIBILITY) {
    monster.mFlags |= IS_INVIS;
    mvaddch(row, col, getMonsterChar(monster));
  } else if (kind == POLYMORPH) {
    if (monster.ichar == 'F') {
      g.beingHeld = false;
    }
    Monster newMonster;
    while (true) {
      newMonster = monsterTab[getRand(0, MONSTERS - 1)].copy();
      if (!(newMonster.ichar == 'X' && (g.currentLevel < XEROC1 || g.currentLevel > XEROC2))) {
        break;
      }
    }
    newMonster.whatIs = MONSTER;
    newMonster.row = row;
    newMonster.col = col;

    final index = g.levelMonsters.indexOf(monster);
    g.levelMonsters[index] = newMonster;

    wakeUp(monster);
    if (canSee(row, col)) {
      mvaddch(row, col, getMonsterChar(monster));
    }
  } else if (kind == PUT_TO_SLEEP) {
    monster.mFlags |= IS_ASLEEP;
    monster.mFlags &= ~WAKENS;
  } else if (kind == DO_NOTHING) {
    message("nothing happens", 0);
  }
  // seems that original never identified wands
  if (idWands[kind].idStatus != CALLED) {
    idWands[kind].idStatus = IDENTIFIED;
  }
}

void teleportAway(Monster monster) {
  if (monster.ichar == 'F') {
    g.beingHeld = false;
  }
  final (row, col) = getRandRowCol(FLOOR | TUNNEL | IS_OBJECT);
  removeMask(monster.row, monster.col, MONSTER);
  mvaddch(monster.row, monster.col, getRoomChar(screen[monster.row][monster.col], monster.row, monster.col));
  monster.row = row;
  monster.col = col;
  addMask(row, col, MONSTER);

  if (canSee(row, col)) {
    mvaddch(row, col, getMonsterChar(monster));
  }
}
