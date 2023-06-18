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

void inventory(List<Object> pack, int mask) {
  var i = 0;
  var maxlen = 27;
  final descriptions = List<String>.filled(MAX_PACK_COUNT + 1, "");

  for (final obj in pack) {
    if ((obj.whatIs & mask) != 0) {
      descriptions[i] = " ${obj.ichar}) ${getDescription(obj)}";
      maxlen = max(maxlen, descriptions[i].length);
      i += 1;
    }
  }
  descriptions[i] = " --press space to continue--";
  final col = COLS - maxlen - 2;

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
  waitForAck(false);

  move(0, 0);
  clrtoeol();

  for (var j = 1; j <= i; j++) {
    mvaddstr(j, col, descriptions[j - 1]);
  }
}

void shuffleColors() {
  for (var i = 0; i < POTIONS; i++) {
    final j = getRand(0, POTIONS - 1);
    final k = getRand(0, POTIONS - 1);
    final temp = idPotions[j].title;
    idPotions[j].title = idPotions[k].title;
    idPotions[k].title = temp;
  }
}

void makeScrollTitles() {
  for (var i = 0; i < SCROLLS; i++) {
    final sylls = getRand(2, 5);
    var title = "'";
    for (var j = 0; j < sylls; j++) {
      title += syllables[getRand(0, MAXSYLLABLES - 1)];
    }
    title = "${title.substring(0, title.length - 1)}' ";
    idScrolls[i].title = title;
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

  final itemName = nameOf(obj);

  if (obj.whatIs == FOOD) {
    description += "$itemName of food ";
    return description;
  }

  final idTable = getIdTable(obj);
  final title = idTable[obj.whichKind].title;

  final k = idTable[obj.whichKind].idStatus;
  if (k == UNIDENTIFIED && !(obj.whatIs & (WEAPON | ARMOR | WAND) != 0 && obj.identified != 0)) {
    final kk = obj.whatIs;
    if (kk == SCROLL) {
      description += "$itemName entitled: $title";
    } else if (kk == POTION) {
      description += "$title$itemName";
    } else if (kk == WAND) {
      description += "$title$itemName";
    } else if (kk == ARMOR) {
      description = title;
      if (obj == rogue.armor) {
        description += "being worn";
      }
    } else if (kk == WEAPON) {
      description += itemName;
      if (obj == rogue.weapon) {
        description += "in hand";
      }
    }
  } else if (k == CALLED) {
    final kk = obj.whatIs;
    if (kk == SCROLL || kk == POTION || kk == WAND) {
      description += "$itemName called $title";
      if (obj.identified != 0) {
        description += "[${obj.clasz}]";
      }
    }
  } else if (k == IDENTIFIED || (obj.whatIs & (WEAPON | ARMOR | WAND) != 0 && obj.identified != 0)) {
    final kk = obj.whatIs;
    if (kk == SCROLL || kk == POTION || kk == WAND) {
      description += "$itemName${idTable[obj.whichKind].real}";
      if (kk == WAND && obj.identified != 0) {
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
          "${obj.toHitEnchantment},${obj.damageEnchantment} $itemName";
      if (obj == rogue.weapon) {
        description += "in hand";
      }
    }
  }
  return description;
}

void mixMetals() {
  for (var i = 0; i < MAXMETALS; i++) {
    final j = getRand(0, MAXMETALS - 1);
    final k = getRand(0, MAXMETALS - 1);
    final temp = metals[j];
    metals[j] = metals[k];
    metals[k] = temp;
  }
  for (var i = 0; i < WANDS; i++) {
    idWands[i].title = metals[i];
  }
}

void singleInventory() {
  final ch = getPackLetter("inventory what? ", IS_OBJECT);

  if (ch == CANCEL) {
    return;
  }

  final obj = getLetterObject(ch);
  if (obj == null) {
    message("No such item.", 0);
    return;
  }

  message("$ch) ${getDescription(obj)}", 0);
}

List<Identity> getIdTable(Object obj) {
  final k = obj.whatIs;
  if (k == SCROLL) {
    return idScrolls;
  }
  if (k == POTION) {
    return idPotions;
  }
  if (k == WAND) {
    return idWands;
  }
  if (k == WEAPON) {
    return idWeapons;
  }
  if (k == ARMOR) {
    return idArmors;
  }
  throw Exception('Invalid object type');
}
