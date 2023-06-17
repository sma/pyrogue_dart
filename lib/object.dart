import 'globals.dart';

void putObjects() {
  if (g.currentLevel < g.maxLevel) return;

  var n = getRand(2, 4);
  if (randPercent(35)) n += 1;

  if (randPercent(50)) {
    idWeapons[SHURIKEN].title = "daggers ";
  }
  if (randPercent(5)) {
    makeParty();
  }
  for (var i = 0; i < n; i++) {
    var obj = getRandObject();
    putObjectRandLocation(obj);
    addToPack(obj, g.levelObjects, false);
  }
  putGold();
}

void putGold() {
  for (var i = 0; i < MAXROOMS; i++) {
    var r = rooms[i];
    if (r.isRoom && randPercent(GOLD_PERCENT)) {
      for (var j = 0; j < 25; j++) {
        var row = getRand(r.topRow + 1, r.bottomRow - 1);
        var col = getRand(r.leftCol + 1, r.rightCol - 1);
        if (screen[row][col] == FLOOR || screen[row][col] == PASSAGE) {
          putGoldAt(row, col);
          break;
        }
      }
    }
  }
}

void putGoldAt(int row, int col) {
  var obj = getAnObject();
  obj.row = row;
  obj.col = col;
  obj.whatIs = GOLD;
  obj.quantity = getRand(2 * g.currentLevel, 16 * g.currentLevel);
  addMask(row, col, GOLD);
  addToPack(obj, g.levelObjects, false);
}

void putObjectAt(Object obj, int row, int col) {
  obj.row = row;
  obj.col = col;
  addMask(row, col, obj.whatIs);
  addToPack(obj, g.levelObjects, false);
}

Object? objectAt(List<Object> pack, int row, int col) {
  for (var obj in pack) {
    if (obj.row == row && obj.col == col) return obj;
  }
  return null;
}

Object? getLetterObject(String ch) {
  for (var obj in rogue.pack) {
    if (obj.ichar == ch) return obj;
  }
  return null;
}

String nameOf(Object obj) {
  var w = obj.whatIs;
  if (w == SCROLL) {
    return obj.quantity > 1 ? "scrolls " : "scroll ";
  }
  if (w == POTION) {
    return obj.quantity > 1 ? "potions " : "potion ";
  }
  if (w == FOOD) {
    return obj.quantity > 1 ? "rations " : "ration ";
  }
  if (w == WAND) {
    return "wand ";
  }
  if (w == WEAPON) {
    var k = obj.whichKind;
    if (k == ARROW) {
      return obj.quantity > 1 ? "arrows " : "arrow ";
    }
    if (k == SHURIKEN) {
      if (idWeapons[k].title[0] == 'd') {
        return obj.quantity > 1 ? "daggers " : "dagger ";
      } else {
        return obj.quantity > 1 ? "shurikens " : "shuriken ";
      }
    }
    return idWeapons[k].title;
  }
  if (w == ARMOR) {
    return idArmors[obj.whichKind].title;
  }
  return "unknown ";
}

Object getRandObject() {
  var obj = getAnObject();
  if (g.foods < g.currentLevel / 2) {
    obj.whatIs = FOOD;
  } else {
    obj.whatIs = getRandWhatIs();
  }
  obj.identified = 0;

  var w = obj.whatIs;
  if (w == SCROLL) {
    getRandScroll(obj);
  } else if (w == POTION) {
    getRandPotion(obj);
  } else if (w == WEAPON) {
    getRandWeapon(obj);
  } else if (w == ARMOR) {
    getRandArmor(obj);
  } else if (w == WAND) {
    getRandWand(obj);
  } else if (w == FOOD) {
    g.foods += 1;
    getFood(obj);
  }

  return obj;
}

int getRandWhatIs() {
  var percent = getRand(1, 92);

  if (percent <= 30) {
    return SCROLL;
  }
  if (percent <= 60) {
    return POTION;
  }
  if (percent <= 65) {
    return WAND;
  }
  if (percent <= 75) {
    return WEAPON;
  }
  if (percent <= 85) {
    return ARMOR;
  }
  return FOOD;
}

void getRandScroll(Object obj) {
  var percent = getRand(0, 82);

  if (percent <= 5) {
    obj.whichKind = PROTECT_ARMOR;
  } else if (percent <= 11) {
    obj.whichKind = HOLD_MONSTER;
  } else if (percent <= 20) {
    obj.whichKind = CREATE_MONSTER;
  } else if (percent <= 35) {
    obj.whichKind = IDENTIFY;
  } else if (percent <= 43) {
    obj.whichKind = TELEPORT;
  } else if (percent <= 52) {
    obj.whichKind = SLEEP;
  } else if (percent <= 57) {
    obj.whichKind = SCARE_MONSTER;
  } else if (percent <= 66) {
    obj.whichKind = REMOVE_CURSE;
  } else if (percent <= 71) {
    obj.whichKind = ENCHANT_ARMOR;
  } else if (percent <= 76) {
    obj.whichKind = ENCHANT_WEAPON;
  } else {
    obj.whichKind = AGGRAVATE_MONSTER;
  }
}

void getRandPotion(Object obj) {
  var percent = getRand(1, 105);

  if (percent <= 5) {
    obj.whichKind = RAISE_LEVEL;
  } else if (percent <= 15) {
    obj.whichKind = DETECT_OBJECTS;
  } else if (percent <= 25) {
    obj.whichKind = DETECT_MONSTER;
  } else if (percent <= 35) {
    obj.whichKind = INCREASE_STRENGTH;
  } else if (percent <= 45) {
    obj.whichKind = RESTORE_STRENGTH;
  } else if (percent <= 55) {
    obj.whichKind = HEALING;
  } else if (percent <= 65) {
    obj.whichKind = EXTRA_HEALING;
  } else if (percent <= 75) {
    obj.whichKind = BLINDNESS;
  } else if (percent <= 85) {
    obj.whichKind = HALLUCINATION;
  } else if (percent <= 95) {
    obj.whichKind = CONFUSION;
  } else {
    obj.whichKind = POISON;
  }
}

void getRandWeapon(Object obj) {
  obj.whichKind = getRand(0, WEAPONS - 1);

  if (obj.whichKind == ARROW || obj.whichKind == SHURIKEN) {
    obj.quantity = getRand(3, 15);
    obj.quiver = getRand(0, 126);
  } else {
    obj.quantity = 1;
  }
  obj.identified = 0;
  obj.toHitEnchantment = 0;
  obj.damageEnchantment = 0;

  var percent = getRand(1, obj.whichKind == LONG_SWORD ? 32 : 96);
  var blessing = getRand(1, 3);
  obj.isCursed = 0;

  var increment = 0;
  if (percent <= 16) {
    increment = 1;
  } else if (percent <= 32) {
    increment = -1;
    obj.isCursed = 1;
  }
  if (percent <= 32) {
    for (var i = 0; i < blessing; i++) {
      if (randPercent(50)) {
        obj.toHitEnchantment += increment;
      } else {
        obj.damageEnchantment += increment;
      }
    }
  }
  var k = obj.whichKind;
  if (k == BOW) {
    obj.damage = "1d2";
  } else if (k == ARROW) {
    obj.damage = "1d2";
  } else if (k == SHURIKEN) {
    obj.damage = "1d4";
  } else if (k == MACE) {
    obj.damage = "2d3";
  } else if (k == LONG_SWORD) {
    obj.damage = "3d4";
  } else if (k == TWO_HANDED_SWORD) {
    obj.damage = "4d5";
  }
}

void getRandArmor(Object obj) {
  obj.whichKind = getRand(0, ARMORS - 1);
  obj.clasz = obj.whichKind + 2;
  if (obj.whichKind == PLATE || obj.whichKind == SPLINT) {
    obj.clasz -= 1;
  }
  obj.isCursed = 0;
  obj.isProtected = 0;
  obj.damageEnchantment = 0;

  var percent = getRand(1, 100);
  var blessing = getRand(1, 3);

  if (percent <= 16) {
    obj.isCursed = 1;
    obj.damageEnchantment -= blessing;
  } else if (percent <= 33) {
    obj.damageEnchantment += blessing;
  }
}

void getRandWand(Object obj) {
  obj.whichKind = getRand(0, WANDS - 1);
  obj.clasz = getRand(3, 7);
}

void getFood(Object obj) {
  obj.whichKind = FOOD;
  obj.whatIs = FOOD;
}

void putStairs() {
  var (row, col) = getRandRowCol(FLOOR | TUNNEL);
  screen[row][col] = STAIRS;
}

int getArmorClass(Object? obj) {
  if (obj != null) {
    return obj.clasz + obj.damageEnchantment;
  }
  return 0;
}

Object getAnObject() {
  return Object(0, "", 1, 'L', 0, 0, 0, 0, 0, 0);
}

void makeParty() {
  g.partyRoom = getRandRoom();
  fillRoomWithMonsters(g.partyRoom, fillRoomWithObjects(g.partyRoom));
}

void showObjects() {
  for (var obj in g.levelObjects) {
    mvaddch(obj.row, obj.col, getRoomChar(obj.whatIs, obj.row, obj.col));
  }
}

void putAmulet() {
  var obj = getAnObject();
  obj.whatIs = AMULET;
  putObjectRandLocation(obj);
  addToPack(obj, g.levelObjects, false);
}

void putObjectRandLocation(Object obj) {
  var (row, col) = getRandRowCol(FLOOR | TUNNEL);
  addMask(row, col, obj.whatIs);
  obj.row = row;
  obj.col = col;
}
