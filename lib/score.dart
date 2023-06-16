import 'dart:convert';
import 'dart:io';

import 'globals.dart';

const String SCOREFILE = "scores";

void killedBy(Monster? monster, int other) {
  //signal(SIGINT, SIG_IGN)

  if (other != QUIT) {
    rogue.gold = rogue.gold * 9 ~/ 10;
  }

  String buf;
  if (other == HYPOTHERMIA) {
    buf = "died of hypothermia";
  } else if (other == STARVATION) {
    buf = "died of starvation";
  } else if (other == QUIT) {
    buf = "quit";
  } else {
    buf = "killed by ";
    String name = monsterNames[monster!.ichar.codeUnitAt(0) - 'A'.codeUnitAt(0)];
    if (isVowel(name)) {
      buf += "an ";
    } else {
      buf += "a ";
    }
    buf += name;
  }

  buf += " with ${rogue.gold} gold";
  message(buf, 0);
  message("", 0);
  score(monster, other);
}

void win() {
  rogue.armor = null;
  rogue.weapon = null;

  clear();
  mvaddstr(10, 11, "@   @  @@@   @   @      @  @  @   @@@   @   @   @");
  mvaddstr(11, 11, " @ @  @   @  @   @      @  @  @  @   @  @@  @   @");
  mvaddstr(12, 11, "  @   @   @  @   @      @  @  @  @   @  @ @ @   @");
  mvaddstr(13, 11, "  @   @   @  @   @      @  @  @  @   @  @  @@");
  mvaddstr(14, 11, "  @    @@@    @@@        @@ @@    @@@   @   @   @");
  mvaddstr(17, 11, "Congratulations,  you have  been admitted  to  the");
  mvaddstr(18, 11, "Fighter's Guild.   You return home,  sell all your");
  mvaddstr(19, 11, "treasures at great profit and retire into comfort.");
  message("", 0);
  message("", 0);
  idAll();
  sellPack();
  score(null, WIN);
}

void quit() {
  message("really quit?", 1);
  if (getchar() != 'y') {
    checkMessage();
    return;
  }
  checkMessage();
  killedBy(null, QUIT);
}

void score(Monster? monster, int other) {
  // todo loop in case the scores file cannot be accessed/created
  putScores(monster, other);
}

void putScores(Monster? monster, int other) {
  List<String> scores = List<String>.filled(10, "");

  File file = File(SCOREFILE);
  RandomAccessFile f = file.openSync(mode: FileMode.writeOnlyAppend);
  f.setPositionSync(0);

  int rank = 10;
  int dontInsert = 0;
  int i = 0;
  while (i < 10) {
    //L:
    scores[i] = ascii.decode(f.readSync(18));
    if (scores[i] == "") {
      break;
    }
    if (scores[i].length < 18) {
      message("error in score file format", 1);
      // TODO(sma): this function doesn't exist
      // cleanup("sorry, score file is out of order");
   

 }
    if (ncmp(scores[i].substring(16), g.playerName)) {
      int s = int.parse(scores[i].substring(8, 16));
      if (s <= rogue.gold) {
        //goto L
        continue;
      }
      dontInsert = 1;
    }
    i += 1;
  }

  //if dont_insert: goto DI
  if (dontInsert == 0) {
    for (int j = 0; j < i; j++) {
      if (rank > 9) {
        int s = int.parse(scores[j].substring(8, 16));
        if (s <= rogue.gold) {
          rank = j;
        }
      }
    }

    if (i == 0) {
      rank = 0;
    } else if (i < 10 && rank > 9) {
      rank = i;
    }
    if (rank <= 9) {
      insertScore(scores, rank, i, monster, other);
      if (i < 10) {
        i += 1;
      }
    }

    f.truncateSync(0);
  }

  //DI:
  clear();
  mvaddstr(3, 30, "Top  Ten  Rogueists");
  mvaddstr(8, 0, "Rank    Score   Name");

  //signal(SIGQUIT, SIG_IGN)
  //signal(SIGINT, SIG_IGN)
  //signal(SIGHUP, SIG_IGN)

  for (int j = 0; j < i; j++) {
    if (j == rank) {
      standout();
    }
    scores[j] = "${(j + 1).toString().padLeft(2)}${scores[j].substring(2)}";
    mvaddstr(j + 10, 0, scores[j]);
    if (rank < 10) {
      f.writeStringSync(scores[j]);
    }
    if (j == rank) {
      standend();
    }
  }

  refresh();
  f.closeSync();

  waitForAck(false);

  cleanUp("");
}

void insertScore(List<String> scores, int rank, int n, Monster? monster, int other) {
  for (int i = n - 1; i >= rank; i--) {
    if (i < 9) {
      scores[i + 1] = scores[i];
    }
  }
  String buf = "${(rank + 1).toString().padLeft(2)}      ${rogue.gold.toString().padLeft(5)}   ${g.playerName}: ";

  if (other == HYPOTHERMIA) {
    buf += "died of hypothermia";
  } else if (other == STARVATION) {
    buf += "died of starvation";
  } else if (other == QUIT) {
    buf += "quit";
  } else if (other == WIN) {
    buf += "a total winner";
  } else {
    buf += "killed by ";
    String name = monsterNames[monster!.ichar.codeUnitAt(0) - 'A'.codeUnitAt(0)];
    if (isVowel(name)) {
      buf += "an ";
    } else {
      buf += "a ";
    }
    buf += name;
  }
  buf += " on level ${g.maxLevel} ";
  if (other != WIN && g.hasAmulet) {
    buf += "with amulet";
  }
  buf += "\n";
  scores[rank] = buf;
}

bool isVowel(String ch) {
  return ch.contains(RegExp(r'[aeiou]'));
}

void sellPack() {
  int rows

 = 2;

  clear();

  Object? obj = rogue.pack.nextObject;
  while (obj != null) {
    mvaddstr(1, 0, "Value      Item");
    if (obj.whatIs != FOOD) {
      obj.identified = 1;
      int val = getValue(obj);
      rogue.gold += val;

      if (rows < SROWS) {
        mvaddstr(rows, 0, "${val.toString().padLeft(5)}      ${getDescription(obj)}");
        rows += 1;
      }
    }
    obj = obj.nextObject;
  }
  refresh();
  message("", 0);
}

int getValue(Object obj) {
  int k = obj.whichKind;
  int val;
  if (k == WEAPON) {
    val = idWeapons[k].value;
    if (k == ARROW || k == SHURIKEN) {
      val *= obj.quantity;
    }
    val += obj.damageEnchantment * 85;
    val += obj.toHitEnchantment * 85;
  } else if (k == ARMOR) {
    val = idArmors[k].value;
    val += obj.damageEnchantment * 75;
    if (obj.isProtected == 1) {
      val += 200;
    }
  } else if (k == WAND) {
    val = idWands[k].value * obj.clasz;
  } else if (k == SCROLL) {
    val = idScrolls[k].value * obj.quantity;
  } else if (k == POTION) {
    val = idPotions[k].value * obj.quantity;
  } else if (k == AMULET) {
    val = 5000;
  } else {
    val = 0;
  }
  return val > 10 ? val : 10;
}

void idAll() {
  for (int i = 0; i < SCROLLS; i++) {
    idScrolls[i].idStatus = IDENTIFIED;
  }
  for (int i = 0; i < WEAPONS; i++) {
    idWeapons[i].idStatus = IDENTIFIED;
  }
  for (int i = 0; i < ARMORS; i++) {
    idArmors[i].idStatus = IDENTIFIED;
  }
  for (int i = 0; i < WANDS; i++) {
    idWands[i].idStatus = IDENTIFIED;
  }
  for (int i = 0; i < POTIONS; i++) {
    idPotions[i].idStatus = IDENTIFIED;
  }
}

bool ncmp(String s1, String s2) {
  return s1.substring(0, s1.indexOf(":")) == s2;
}