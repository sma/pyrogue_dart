void quaff() {
  final ch = getPackLetter("quaff what? ", POTION);
  if (ch == CANCEL) {
    return;
  }
  final obj = getLetterObject(ch);
  if (obj == null) {
    message("no such item.", 0);
    return;
  }
  if (obj.whatIs != POTION) {
    message("you can't drink that", 0);
    return;
  }
  final k = obj.whichKind;
  if (k == INCREASE_STRENGTH) {
    message("you feel stronger now, what bulging muscles!", 0);
    rogue.strengthCurrent += 1;
    if (rogue.strengthCurrent > rogue.strengthMax) {
      rogue.strengthMax = rogue.strengthCurrent;
    }
  } else if (k == RESTORE_STRENGTH) {
    message("this tastes great, you feel warm all over", 0);
    rogue.strengthCurrent = rogue.strengthMax;
  } else if (k == HEALING) {
    message("you begin to feel better", 0);
    potionHeal(0);
  } else if (k == EXTRA_HEALING) {
    message("you begin to feel much better", 0);
    potionHeal(1);
  } else if (k == POISON) {
    rogue.strengthCurrent -= getRand(1, 3);
    if (rogue.strengthCurrent < 0) {
      rogue.strengthCurrent = 0;
    }
    message("you feel very sick now", 0);
    if (g.halluc != 0) {
      unhallucinate();
    }
  } else if (k == RAISE_LEVEL) {
    message("you feel more experienced", 0);
    addExp(levelPoints[rogue.exp - 1] - rogue.expPoints + 1);
  } else if (k == BLINDNESS) {
    goBlind();
  } else if (k == HALLUCINATION) {
    message("oh wow, everything seems so cosmic", 0);
    g.halluc += getRand(500, 800);
  } else if (k == DETECT_MONSTER) {
    if (g.levelMonsters.nextObject != null) {
      showMonsters();
    } else {
      message("you have a strange feeling for a moment, then it passes", 0);
    }
    g.detectMonster = 1;
  } else if (k == DETECT_OBJECTS) {
    if (g.levelObjects.nextObject != null) {
      if (!g.blind) {
        showObjects();
      }
    } else {
      message("you have a strange feeling for a moment, then it passes", 0);
    }
  } else if (k == CONFUSION) {
    message(g.halluc != 0 ? "what a trippy feeling" : "you feel confused", 0);
    confuse();
  }
  printStats();
  if (idPotions[k].idStatus != CALLED) {
    idPotions[k].idStatus = IDENTIFIED;
  }
  vanish(obj, 1);
}

void readScroll() {
  final ch = getPackLetter("read what? ", SCROLL);
  if (ch == CANCEL) {
    return;
  }
  final obj = getLetterObject(ch);
  if (obj == null) {
    message("no such item.", 0);
    return;
  }
  if (obj.whatIs != SCROLL) {
    message("you can't read that", 0);
    return;
  }
  final k = obj

.whichKind;
  if (k == SCARE_MONSTER) {
    message("you hear a maniacal laughter in the distance", 0);
  } else if (k == HOLD_MONSTER) {
    holdMonster();
  } else if (k == ENCHANT_WEAPON) {
    if (rogue.weapon != null) {
      message(
          "your ${idWeapons[rogue.weapon.whichKind].title} glows ${getEnchColor()}for a moment",
          0);
      if (getRand(0, 1) != 0) {
        rogue.weapon.toHitEnchantment += 1;
      } else {
        rogue.weapon.damageEnchantment += 1;
      }
      rogue.weapon.isCursed = 0;
    } else {
      message("your hands tingle", 0);
    }
  } else if (k == ENCHANT_ARMOR) {
    if (rogue.armor != null) {
      message("your armor glows ${getEnchColor()}for a moment", 0);
      rogue.armor.damageEnchantment += 1;
      rogue.armor.isCursed = 0;
      printStats();
    } else {
      message("your skin crawls", 0);
    }
  } else if (k == IDENTIFY) {
    message("this is a scroll of identify", 0);
    message("what would you like to identify?", 0);
    obj.identified = 1;
    idScrolls[k].idStatus = IDENTIFIED;
    identify();
  } else if (k == TELEPORT) {
    teleport();
  } else if (k == SLEEP) {
    sleepScroll();
  } else if (k == PROTECT_ARMOR) {
    if (rogue.armor != null) {
      message("your armor is covered by a shimmering gold shield", 0);
      rogue.armor.isProtected = 1;
    } else {
      message("your acne seems to have disappeared", 0);
    }
  } else if (k == REMOVE_CURSE) {
    message("you feel as though someone is watching over you", 0);
    if (rogue.armor != null) {
      rogue.armor.isCursed = 0;
    }
    if (rogue.weapon != null) {
      rogue.weapon.isCursed = 0;
    }
  } else if (k == CREATE_MONSTER) {
    createMonster();
  } else if (k == AGGRAVATE_MONSTER) {
    aggravate();
  }
  if (idScrolls[k].idStatus != CALLED) {
    idScrolls[k].idStatus = IDENTIFIED;
  }
  vanish(obj, 1);
}

void vanish(Object obj, int rm) {
  if (obj.quantity > 1) {
    obj.quantity -= 1;
  } else {
    removeFromPack(obj, rogue.pack);
    makeAvailableIchar(obj.ichar);
  }
  if (rm != 0) {
    registerMove();
  }
}

void potionHeal(int extra) {
  final ratio = rogue.hpCurrent / rogue.hpMax.toDouble();
  if (ratio >= 0.9) {
    rogue.hpMax += extra + 1;
    rogue.hpCurrent = rogue.hpMax;
  } else {
    if (ratio < 30.0) {
      ratio = 30.0;
    }
    if (extra != 0) {
      ratio += ratio;
    }
    final add = (ratio * (rogue.hpCurrent - rogue.hpMax)).toInt();
    rogue.hpCurrent = max(rogue.hpCurrent + add, rogue.hpMax);
  }
  if (g

.blind) {
    unblind();
  }
  if (g.confused != 0 && extra != 0) {
    unconfuse();
  } else if (g.confused != 0) {
    g.confused = (g.confused - 9) ~/ 2;
    if (g.confused <= 0) {
      unconfuse();
    }
  }
  if (g.halluc != 0 && extra != 0) {
    unhallucinate();
  } else if (g.halluc != 0) {
    g.halluc = (g.halluc ~/ 2) + 1;
  }
}

void identify() {
  while (true) {
    final ch = getPackLetter("identify what? ", IS_OBJECT);
    if (ch == CANCEL) {
      return;
    }
    final obj = getLetterObject(ch);
    if (obj == null) {
      message("no such item, try again", 0);
      checkMessage();
      continue;
    }
    obj.identified = 1;
    if (obj.whatIs &
        (SCROLL | POTION | WEAPON | ARMOR | WAND) !=
        0) {
      final idTable = getIdTable(obj);
      idTable[obj.whichKind].idStatus = IDENTIFIED;
    }
    message(getDescription(obj), 0);
    return;
  }
}

void eat() {
  final ch = getPackLetter("eat what? ", FOOD);
  if (ch == CANCEL) {
    return;
  }
  final obj = getLetterObject(ch);
  if (obj == null) {
    message("no such item.", 0);
    return;
  }
  if (obj.whatIs != FOOD) {
    message("you can't eat that", 0);
    return;
  }
  final moves = getRand(800, 1000);
  if (moves >= 900) {
    message("yum, that tasted good", 0);
  } else {
    message("yuk, that food tasted awful", 0);
    addExp(3);
  }
  rogue.movesLeft ~/= 2;
  rogue.movesLeft += moves;
  g.hungerStr = "";
  printStats();
  vanish(obj, 1);
}

void holdMonster() {
  var mcount = 0;
  for (var i = -2; i < 3; i++) {
    for (var j = -2; j < 3; j++) {
      final row = rogue.row + i;
      final col = rogue.col + j;
      if (row < MIN_ROW ||
          row > LINES - 2 ||
          col < 0 ||
          col > COLS - 1) {
        continue;
      }
      if ((screen[row][col] & MONSTER) != 0) {
        final monster = objectAt(g.levelMonsters, row, col);
        monster.mFlags |= IS_ASLEEP;
        monster.mFlags &= ~WAKENS;
        mcount += 1;
      }
    }
  }
  if (mcount == 0) {
    message("you feel a strange sense of loss", 0);
  } else if (mcount == 1) {
    message("the monster freezes", 0);
  } else {
    message("the monsters around you freeze", 0);
  }
}

void teleport() {
  if (g.currentRoom >= 0) {
    darkenRoom(g.currentRoom);
  } else {
    mvaddch(
        rogue.row, rogue.col, getRoomChar(screen[rogue.row][rogue.col], rogue.row, rogue

.col));
  }
  putPlayer();
  lightUpRoom();
  g.beingHold = 0;
}

void hallucinate() {
  if (g.blind) {
    return;
  }
  var obj = g.levelObjects.nextObject;
  while (obj != null) {
    final ch = mvinch(obj.row, obj.col);
    if ((ch < 'A' || ch > 'Z') && (obj.row != rogue.row || obj.col != rogue.col)) {
      if (ch != ' ' && ch != '.' && ch != '#' && ch != '+') {
        addch(getRandObjChar());
      }
    }
    obj = obj.nextObject;
  }
  obj = g.levelMonsters.nextObject;
  while (obj != null) {
    final ch = mvinch(obj.row, obj.col);
    if (ch >= 'A' && ch <= 'Z') {
      addch(String.fromCharCode(getRand('A'.codeUnitAt(0), 'Z'.codeUnitAt(0))));
    }
    obj = obj.nextObject;
  }
}

void unhallucinate() {
  g.halluc = 0;
  if (g.currentRoom == PASSAGE) {
    lightPassage(rogue.row, rogue.col);
  } else {
    lightUpRoom();
  }
  message("everything looks SO boring now", 0);
}

void unblind() {
  g.blind = 0;
  message("the veil of darkness lifts", 0);
  if (g.currentRoom == PASSAGE) {
    lightPassage(rogue.row, rogue.col);
  } else {
    lightUpRoom();
  }
  if (g.detectMonster) {
    showMonsters();
  }
  if (g.halluc) {
    hallucinate();
  }
}

void sleepScroll() {
  message("you fall asleep", 0);
  var i = getRand(4, 10);
  while (i != 0) {
    moveMonsters();
    i -= 1;
  }
  message("you can move again", 0);
}

void goBlind() {
  if (g.blind == 0) {
    message("a cloak of darkness falls around you", 0);
  }
  g.blind += getRand(500, 800);
  if (g.currentRoom >= 0) {
    final r = rooms[g.currentRoom];
    for (var i = r.topRow + 1; i < r.bottomRow; i++) {
      for (var j = r.leftCol + 1; j < r.rightCol; j++) {
        mvaddch(i, j, ' ');
      }
    }
  }
  mvaddch(rogue.row, rogue.col, rogue.fchar);
  refresh();
}

String getEnchColor() {
  if (g.halluc != 0) {
    return idPotions[getRand(0, POTIONS - 1)].title;
  }
  return "blue ";
}

void confuse() {
  g.confused = getRand(12, 22);
}

void unconfuse() {
  g.confused = 0;
  message("you feel less ${g.halluc != 0 ? "trippy" : "confused"} now", 0);
}