import 'globals.dart';

void playLevel() {
  int count = 0;
  while (true) {
    g.interrupted = 0;
    if (g.hitMessage.isNotEmpty) {
      message(g.hitMessage, 0);
      g.hitMessage = '';
    }

    move(rogue.row, rogue.col);
    refresh();

    String ch = getchar();
    checkMessage();

    while (true) {
      if (ch == '.') {
        rest(count > 0 ? count : 1);
      } else if (ch == 'i') {
        inventory(rogue.pack, IS_OBJECT);
      } else if (ch == 'f') {
        fight(0);
      } else if (ch == 'F') {
        fight(1);
      } else if (ch == 'h' || ch == 'j' || ch == 'k' || ch == 'l' || ch == 'y' || ch == 'u' || ch == 'n' || ch == 'b') {
        singleMoveRogue(ch, 1);
      } else if (ch == 'H' || ch == 'J' || ch == 'K' || ch == 'L' || ch == 'Y' || ch == 'U' || ch == 'N' || ch == 'B' ||
                 ch == '\010' || ch == '\012' || ch == '\013' || ch == '\014' || ch == '\031' || ch == '\025' || ch == '\016' || ch == '\002') {
        multipleMoveRogue(ch);
      } else if (ch == 'e') {
        eat();
      } else if (ch == 'q') {
        quaff();
      } else if (ch == 'r') {
        readScroll();
      } else if (ch == 'm') {
        moveOnto();
      } else if (ch == 'd') {
        drop();
      } else if (ch == '\020') {
        remessage();
      } else if (ch == '>') {
        if (checkDown()) {
          return;
        }
      } else if (ch == '<') {
        if (checkUp()) {
          return;
        }
      } else if (ch == 'I') {
        singleInventory();
      } else if (ch == '\022') {
        refresh();
      } else if (ch == 'T') {
        takeOff();
      } else if (ch == 'W' || ch == 'P') {
        wear();
      } else if (ch == 'w') {
        wield();
      } else if (ch == 'c') {
        callIt();
      } else if (ch == 'z') {
        zapp();
      } else if (ch == 't') {
        throwObj();
      } else if (ch == '\032') {
        tstp();
      } else if (ch == '!') {
        shell();
      } else if (ch == 'v') {
        message("pyrogue: Version 1.0 (sma was here)", 0);
      } else if (ch == 'Q') {
        quit();
      } else if (ch >= '0' && ch <= '9') {
        count = 0;
        while (true) {
          count = 10 * count + ch.codeUnitAt(0) - '0'.codeUnitAt(0);
          ch = getchar();
          if (ch < '0' || ch > '9') break;
        }
        continue;
      } else if (ch == ' ') {
        // Do nothing
      } else {
        message("unknown command");
      }
      break;
    }
  }
}