import 'globals.dart';

String CURSE_MESSAGE = "you can't, it appears to be cursed";

Object addToPack(Object obj, Object pack, bool condense) {
  if (condense) {
    Object op = checkDuplicate(obj, pack);
    if (op != null) {
      return op;
    } else {
      obj.ichar = nextAvailIchar();
    }
  }
  if (pack.nextObject == null) {
    pack.nextObject = obj;
  } else {
    Object op = pack.nextObject;
    while (op.nextObject != null) {
      op = op.nextObject;
    }
    op.nextObject = obj;
  }
  obj.nextObject = null;
  return obj;
}

void removeFromPack(Object obj, Object pack) {
  while (pack.nextObject != obj) {
    pack = pack.nextObject;
  }
  pack.nextObject = pack.nextObject.nextObject;
}

Object pickUp(int row, int col) {
  Object obj = objectAt(g.levelObjects, row, col);
  int status = 1;

  if (obj.whatIs == SCROLL && obj.whichKind == SCARE_MONSTER && obj.pickedUp > 0) {
    message("the scroll turns to dust as you pick it up", 1);
    removeFromPack(obj, g.levelObjects);
    removeMask(row, col, SCROLL);
    status = 0;
    idScrolls[SCARE_MONSTER].idStatus = IDENTIFIED;
    return null;
  }

  if (obj.whatIs == GOLD) {
    rogue.gold += obj.quantity;
    removeMask(row, col, GOLD);
    removeFromPack(obj, g.levelObjects);
    printStats();
    return obj;
  }

  if (getPackCount(obj) >= MAX_PACK_COUNT) {
    message("Pack too full", 1);
    return null;
  }

  if (obj.whatIs == AMULET) {
    g.hasAmulet = 1;
  }

  removeMask(row, col, obj.whatIs);
  removeFromPack(obj, g.levelObjects);
  obj = addToPack(obj, rogue.pack, true);
  obj.pickedUp += 1;
  return obj;
}

void drop() {
  if (screen[rogue.row][rogue.col] & IS_OBJECT) {
    message("There's already something there", 0);
    return;
  }
  if (rogue.pack.nextObject == null) {
    message("You have nothing to drop", 0);
    return;
  }
  String ch = getPackLetter("drop what? ", IS_OBJECT);
  if (ch == CANCEL) {
    return;
  }
  Object obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }
  if (obj == rogue.weapon) {
    if (obj.isCursed) {
      message(CURSE_MESSAGE, 0);
      return;
    }
    rogue.weapon = null;
  } else if (obj == rogue.armor) {
    if (obj.isCursed) {
      message(CURSE_MESSAGE, 0);
      return;
    }
    rogue.armor = null;
    printStats();
  }

  obj.row = rogue.row;
  obj.col = rogue.col;

  if (obj.quantity > 1 && obj.whatIs != WEAPON) {
    obj.quantity -= 1;
    Object newObj = getAnObject();
    newObj = obj.copy();
    newObj.quantity = 1;
    obj = newObj;
    addToPack(obj, g.levelObjects, false);
    addMask(rogue.row, rogue.col, obj.whatIs);
    message("dro

pped " + getDescription(obj), 0);
    registerMove();
    return;
  }

  if (obj.whatIs == AMULET) {
    g.hasAmulet = 0;
  }

  makeAvailIchar(obj.ichar);
  removeFromPack(obj, rogue.pack);
  addToPack(obj, g.levelObjects, false);
  addMask(rogue.row, rogue.col, obj.whatIs);
  message("dropped " + getDescription(obj), 0);
  registerMove();
}

Object checkDuplicate(Object obj, Object pack) {
  if (!((obj.whatIs & (WEAPON | FOOD | SCROLL | POTION)) != 0)) {
    return null;
  }
  Object op = pack.nextObject;
  while (op != null) {
    if (op.whatIs == obj.whatIs && op.whichKind == obj.whichKind) {
      if (obj.whatIs != WEAPON ||
          (obj.whatIs == WEAPON && (obj.whichKind == ARROW || obj.whichKind == SHURIKEN) && obj.quiver == op.quiver)) {
        op.quantity += obj.quantity;
        return op;
      }
    }
    op = op.nextObject;
  }
  return null;
}

String nextAvailIchar() {
  for (int i = 0; i < 26; i++) {
    if (!g.ichars[i]) {
      g.ichars[i] = true;
      return String.fromCharCode(i + 97);
    }
  }
  return '';
}

void makeAvailIchar(String ch) {
  g.ichars[ch.codeUnitAt(0) - 97] = false;
}

void waitForAck(bool prompt) {
  if (prompt) {
    addstr(MORE);
  }
  while (getchar() != ' ') {}
}

String getPackLetter(String prompt, int mask) {
  bool firstMiss = true;
  message(prompt, 0);
  String ch = getchar();
  while (true) {
    while (!isPackLetter(ch)) {
      if (ch != '') {
        beep();
      }
      if (firstMiss) {
        message(prompt, 0);
        firstMiss = false;
      }
      ch = getchar();
    }
    if (ch == LIST) {
      checkMessage();
      inventory(rogue.pack, mask);
      firstMiss = true;
      ch = '';
      continue;
    }
    break;
  }
  checkMessage();
  return ch;
}

void takeOff() {
  if (rogue.armor != null) {
    if (rogue.armor.isCursed) {
      message(CURSE_MESSAGE, 0);
    } else {
      mvAquatars();
      Object obj = rogue.armor;
      rogue.armor = null;
      message("was wearing " + getDescription(obj), 0);
      printStats();
      registerMove();
    }
  } else {
    message("not wearing any", 0);
  }
}

void wear() {
  if (rogue.armor != null) {
    message("your already wearing some", 0);
    return;
  }
  String ch = getPackLetter("wear what? ", ARMOR);
  if (ch == CANCEL) {
    return;
  }
  Object obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }
  if (obj.whatIs != ARMOR) {
    message("You can't wear that", 0);
    return;
  }
  rogue.armor = obj;
  obj.identified = 1;
  message(getDescription(obj), 0);
  printStats();
  registerMove

();
}

void wield() {
  if (rogue.weapon != null && rogue.weapon.isCursed) {
    message(CURSE_MESSAGE, 0);
    return;
  }
  String ch = getPackLetter("wield what? ", WEAPON);
  if (ch == CANCEL) {
    return;
  }
  Object obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }
  if (obj.whatIs != WEAPON) {
    message("You can't wield that", 0);
    return;
  }
  if (obj == rogue.weapon) {
    message("in use", 0);
  } else {
    rogue.weapon = obj;
    message(getDescription(obj), 0);
    registerMove();
  }
}

void callIt() {
  String ch = getPackLetter("call what? ", SCROLL | POTION | WAND);
  if (ch == CANCEL) {
    return;
  }
  Object obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }
  if ((obj.whatIs & (SCROLL | POTION | WAND)) == 0) {
    message("surely you already know what that's called", 0);
    return;
  }
  List<IdTable> idTable = getIdTable(obj);

  String buf = getInputLine(idTable[obj.whichKind].title, false);
  if (buf != '') {
    idTable[obj.whichKind].idStatus = CALLED;
    idTable[obj.whichKind].title = buf;
  }
}

int getPackCount(Object newObj) {
  int count = 0;

  Object obj = rogue.pack.nextObject;
  while (obj != null) {
    if (obj.whatIs != WEAPON) {
      count += obj.quantity;
    } else {
      if (newObj.whatIs != WEAPON ||
          (newObj.whichKind != ARROW && newObj.whichKind != SHURIKEN) ||
          newObj.whichKind != obj.whichKind ||
          newObj.quiver != obj.quiver) {
        count += 1;
      }
    }
    obj = obj.nextObject;
  }

  return count;
}