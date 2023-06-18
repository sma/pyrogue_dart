import 'globals.dart';

void monsterHit(Monster monster, String? other) {
  if (g.fightMonster != null && monster != g.fightMonster) {
    g.fightMonster = null;
  }
  monster.trow = -1;
  var hitChance = monster.clasz;
  hitChance -= rogue.exp + rogue.exp;
  if (hitChance < 0) hitChance = 0;

  if (g.fightMonster == null) {
    g.interrupted = true;
  }

  final mn = monsterName(monster);

  if (!randPercent(hitChance)) {
    if (g.fightMonster == null) {
      g.hitMessage += "the ${other ?? mn} misses";
      message(g.hitMessage, 0);
      g.hitMessage = "";
    }
    return;
  }

  if (g.fightMonster == null) {
    g.hitMessage += "the ${other ?? mn} hit";
    message(g.hitMessage, 0);
    g.hitMessage = "";
  }

  int damage;
  if (monster.ichar != 'F') {
    damage = getDamage(monster.damage, 1);
    final minus = (getArmorClass(rogue.armor) * 3.0) / 100.0 * damage;
    damage -= minus.toInt();
  } else {
    damage = monster.identified;
    monster.identified += 1;
  }

  if (damage > 0) {
    rogueDamage(damage, monster);
  }

  specialHit(monster);
}

void rogueHit(Monster monster) {
  if (checkXeroc(monster)) {
    return;
  }
  final hitChance = getHitChance(rogue.weapon);
  if (!randPercent(hitChance)) {
    if (g.fightMonster == null) {
      g.hitMessage = "you miss  ";
    }
    checkOrc(monster);
    wakeUp(monster);
    return;
  }

  final damage = getWeaponDamage(rogue.weapon);
  if (monsterDamage(monster, damage)) {
    if (g.fightMonster == null) {
      g.hitMessage = "you hit  ";
    }
  }

  checkOrc(monster);
  wakeUp(monster);
}

void rogueDamage(int d, Monster monster) {
  if (d >= rogue.hpCurrent) {
    rogue.hpCurrent = 0;
    printStats();
    killedBy(monster, 0);
  }
  rogue.hpCurrent -= d;
  printStats();
}

int getDamage(String ds, int r) {
  var total = 0;
  var i = 0;
  while (i < ds.length) {
    final n = getNumber(ds.substring(i));
    while (i < ds.length && ds[i] != 'd') {
      i += 1;
    }
    i += 1;
    final d = getNumber(ds.substring(i));
    while (i < ds.length && ds[i] != '/') {
      i += 1;
    }
    for (var j = 0; j < n; j++) {
      if (r != 0) {
        total += getRand(1, d);
      } else {
        total += d;
      }
    }
    if (i < ds.length && ds[i] == '/') {
      i += 1;
    }
  }
  return total;
}

int getWDamage(Object? obj) {
  if (obj == null) {
    return -1;
  }
  final toHit = getNumber(obj.damage) + obj.toHitEnchantment;
  var i = 0;
  while (i < obj.damage.length && obj.damage[i] != 'd') {
    i += 1;
  }
  i += 1;
  final damage = getNumber(obj.damage.substring(i)) + obj.damageEnchantment;

  return getDamage("${toHit}d$damage", 1);
}

int getNumber(String s) {
  var total = 0;
  var i = 0;
  while (i < s.length && '0'.compareTo(s[i]) <= 0 && s[i].compareTo('9') <= 0) {
    total = 10 * total + s[i].codeUnitAt(0) - '0'.codeUnitAt(0);
    i += 1;
  }
  return total;
}

int toHit(Object? obj) {
  if (obj == null) {
    return 1;
  }
  return getNumber(obj.damage) + obj.toHitEnchantment;
}

int damageForStrength(int s) {
  if (s <= 6) return s - 5;
  if (s <= 14) return 1;
  if (s <= 17) return 3;
  if (s <= 18) return 4;
  if (s <= 20) return 5;
  if (s <= 21) return 6;
  if (s <= 30) return 7;
  return 8;
}

bool monsterDamage(Monster monster, int damage) {
  monster.quantity -= damage;
  if (monster.quantity <= 0) {
    final row = monster.row;
    final col = monster.col;
    removeMask(row, col, MONSTER);
    mvaddch(row, col, getRoomChar(screen[row][col], row, col));
    refresh();

    g.fightMonster = null;
    coughUp(monster);
    g.hitMessage += "defeated the ${monsterName(monster)}";
    message(g.hitMessage, 1);
    g.hitMessage = "";
    addExp(monster.killExp);
    printStats();
    removeFromPack(monster, g.levelMonsters);

    if (monster.ichar == 'F') {
      g.beingHeld = false;
    }

    return false;
  }
  return true;
}

void fight(bool toTheDeath) {
  var firstMiss = true;
  var ch = getchar();
  while (!isDirection(ch)) {
    beep();
    if (firstMiss) {
      message("direction?", 0);
      firstMiss = false;
    }
    ch = getchar();
  }
  checkMessage();
  if (ch == CANCEL) {
    return;
  }

  final (row, col) = getDirRc(ch, rogue.row, rogue.col);

  if ((screen[row][col] & MONSTER == 0) || g.blind > 0 || hidingXeroc(row, col)) {
    //MN:
    message("I see no monster there", 0);
    return;
  }
  g.fightMonster = objectAt(g.levelMonsters, row, col);
  if ((g.fightMonster!.mFlags & IS_INVIS) != 0 && !g.detectMonster) {
    //goto MN
    message("I see no monster there", 0);
    return;
  }
  final possibleDamage = getDamage(g.fightMonster!.damage, 0) * 2 / 3;

  while (g.fightMonster != null) {
    singleMoveRogue(ch, false);
    if (!toTheDeath && rogue.hpCurrent <= possibleDamage) {
      g.fightMonster = null;
    }
    if ((screen[row][col] & MONSTER == 0) || g.interrupted) {
      g.fightMonster = null;
    }
  }
}

(int, int) getDirRc(String dir, int row, int col) {
  if ('hyb'.contains(dir)) {
    if (col > 0) col -= 1;
  }
  if ('jnb'.contains(dir)) {
    if (row < LINES - 2) row += 1;
  }
  if ('kyu'.contains(dir)) {
    if (row > MIN_ROW) row -= 1;
  }
  if ('lun'.contains(dir)) {
    if (col < COLS - 1) col += 1;
  }
  return (row, col);
}

int getHitChance(Object? weapon) {
  var hitChance = 40;
  hitChance += 3 * toHit(weapon);
  hitChance += rogue.exp + rogue.exp;
  if (hitChance > 100) hitChance = 100;
  return hitChance;
}

int getWeaponDamage(Object? weapon) {
  var damage = getWDamage(weapon);
  damage += damageForStrength(rogue.strengthCurrent);
  damage += (rogue.exp + 1) ~/ 2;
  return damage;
}
