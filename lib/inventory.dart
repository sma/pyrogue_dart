import 'dart:math';

import 'globals.dart';

List<String> metals = [
  "steel ",
  "bronze ",
  "gold ",
  "silver ",
  "copper ",
  "nickel ",
  "cobalt ",
  "tin ",
  "iron ",
  "magnesium ",
  "chrome ",
  "carbon ",
  "platinum ",
  "silicon ",
  "titanium "
];

List<String> syllables = [
  "blech ",
  "foo ",
  "barf ",
  "rech ",
  "bar ",
  "blech ",
  "quo ",
  "bloto ",
  "woh ",
  "caca ",
  "blorp ",
  "erp ",
  "festr ",
  "rot ",
  "slie ",
  "snorf ",
  "iky ",
  "yuky ",
  "ooze ",
  "ah ",
  "bahl ",
  "zep ",
  "druhl ",
  "flem ",
  "behil ",
  "arek ",
  "mep ",
  "zihr ",
  "grit ",
  "kona ",
  "kini ",
  "ichi ",
  "niah ",
  "ogr ",
  "ooh ",
  "ighr ",
  "coph ",
  "swerr ",
  "mihln ",
  "poxi "
];

void initItems() {
  shuffleColors();
  mixMetals();
  makeScrollTitles();
}

void inventory(Pack pack, int mask) {
  var i = 0;
  var maxlen = 27;
  var descriptions = List<String>.filled(MAX_PACK_COUNT + 1, "");

  var obj = pack.nextObject;
  while (obj != null) {
    if ((obj.whatIs & mask) != 0) {
      descriptions[i] = " " + obj.ichar + ") " + getDescription(obj);
      maxlen = max(maxlen, descriptions[i].length);
      i += 1;
    }
    obj = obj.nextObject;
  }
  descriptions[i] = " --press space to continue--";
  var col = COLS - maxlen - 2;

  var row = 0;
  while (row <= i && row < SROWS) {
    if (row > 0) {
      var d = "";
      for (var j = col; j < COLS; j++) {
        d += mvinch(row, j);
      }
      descriptions[row - 1] = d;
    }
    mvaddstr(row, col, descriptions[row]);
    clrtoeol();
    row += 1;
  }
  refresh();
  wait_for_ack("");

  move(0, 0);
  clrtoeol();

  for (var j = 1; j <= i; j++) {
    mvaddstr(j, col, descriptions[j - 1]);
  }
}

void shuffleColors() {
  for (var i = 0; i < POTIONS; i++) {
    var j = getRand(0, POTIONS - 1);
    var k = getRand(0, POTIONS - 1);
    var temp = id_potions[j].title;
    id_potions[j].title = id_potions[k].title;
    id_potions[k].title = temp;
  }
}

void makeScrollTitles() {
  for (var i = 0; i < SCROLLS; i++) {
    var sylls = getRand(2, 5);
    var title = "'";
    for (var j = 0; j < sylls; j++) {
      title += syllables[getRand(0, MAXSYLLABLES - 1)];
    }
    title = title.substring(0, title.length - 1) + "' ";
    id_scrolls[i].title = title;
  }
}

String getDescription(Object obj) {
  if (obj.whatIs == AMULET) {
    return "the amulet of Yendor";
  }

  if (obj.whatIs == GOLD) {
    return "${obj.quantity} pieces of gold";
  }

  var description = "";

  if (obj.whatIs != ARMOR) {
    if (obj.quantity == 1) {
      description = "a ";
    } else {
      description = "${obj.quantity} ";
    }
  }

  var item_name = nameOf(obj);

  if (obj.whatIs == FOOD) {
    description += "$item_name of food ";
    return description;
  }

  var id_table = getIdTable(obj);
  var title = id_table[obj.whichKind].title;

  var k = id_table[obj.whichKind].idStatus;
  if (k == UNIDENTIFIED &&
      !(obj.whatIs & (WEAPON | ARMOR | WAND) != 0 && obj.identified)) {
    var kk = obj.whatIs;
    if (kk == SCROLL) {
      description += "$item_name entitled: $title";
    } else if (kk == POTION) {
      description += "$title$item_name";
    } else if (kk == WAND) {
      description += "$title$item_name";
    } else if (kk == ARMOR) {
      description = title;
      if (obj == rogue.armor) {
        description += "being worn";
      }
    } else if (kk == WEAPON) {
      description += "$item_name";
      if (obj == rogue.weapon) {
        description += "in hand";
      }
    }
  } else if (k == CALLED) {
    var kk = obj.whatIs;
    if (kk == SCROLL || kk == POTION || kk == WAND) {
      description += "$item_name called $title";
      if (obj.identified) {
        description += "[${obj.clasz}]";
      }
    }
  } else if (k == IDENTIFIED ||
      (obj.whatIs & (WEAPON | ARMOR | WAND) != 0 && obj.identified)) {
    var kk = obj.whatIs;
    if (kk == SCROLL || kk == POTION || kk == WAND) {
      description += "$item_name${id_table[obj.whichKind].real}";
      if (kk == WAND && obj.identified) {
        description += "[${obj.clasz}]";
      }
    } else if (kk == ARMOR) {
      description = "${obj.damageEnchantment >= 0 ? '+' : ''}"
          "${obj.damageEnchantment} $title[${getArmorClass(obj)}] ";
      if (obj == rogue.armor) {
        description += "being worn";
      }
    } else if (kk == WEAPON) {
      description += "${obj.toHitEnchantment >= 0 ? '+' : ''}"
          "${obj.toHitEnchantment},${obj.damageEnchantment} $item_name";
      if (obj == rogue.weapon) {
        description += "in hand";
      }
    }
  }
  return description;
}

void mixMetals() {
  for (var i = 0; i < MAXMETALS; i++) {
    var j = getRand(0, MAXMETALS - 1);
    var k = getRand(0, MAXMETALS - 1);
    var temp = metals[j];
    metals[j] = metals[k];
    metals[k] = temp;
  }
  for (var i = 0; i < WANDS; i++) {
    id_wands[i].title = metals[i];
  }
}

void singleInventory() {
  var ch = getPackLetter("inventory what? ", IS_OBJECT);

  if (ch == CANCEL) {
    return;
  }

  var obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }

  message(ch + ") " + getDescription(obj), 0);
}

IdTable getIDTable(Object obj) {
  var k = obj.whatIs;
  if (k == SCROLL) {
    return id_scrolls;
  }
  if (k == POTION) {
    return id_potions;
  }
  if (k == WAND) {
    return id_wands;
  }
  if (k == WEAPON) {
    return id_weapons;
  }
  if (k == ARMOR) {
    return id_armors;
  }
  throw Exception('Invalid object type');
}