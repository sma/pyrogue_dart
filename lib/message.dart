import 'globals.dart';

void message(String msg, [int intrpt = 0]) {
  if (intrpt != 0) {
    g.interrupted = true;
  }
  g.cantInt = true;
  slurp();

  if (!g.messageCleared) {
    mvaddstr(MIN_ROW - 1, g.messageCol, MORE);
    refresh();
    waitForAck(false);
    checkMessage();
  }

  g.messageLine = msg;
  mvaddstr(MIN_ROW - 1, 0, msg);
  addch(' ');
  refresh();
  g.messageCleared = false;
  g.messageCol = msg.length;

  if (g.didInt) {
    onintr();
  }
  g.cantInt = false;
}

void remessage() {
  if (g.messageLine.isNotEmpty) {
    message(g.messageLine, 0);
  }
}

void checkMessage() {
  if (g.messageCleared) {
    return;
  }
  move(MIN_ROW - 1, 0);
  clrtoeol();
  move(rogue.row, rogue.col);
  refresh();
  g.messageCleared = true;
}

String getInputLine(String prompt, bool echo) {
  message(prompt, 0);
  var buf = "";
  while (true) {
    final ch = getchar();
    if (ch == CANCEL) {
      buf = "";
      break;
    }
    if (ch == '\r' || ch == '\n') {
      break;
    }
    if (ch.codeUnitAt(0) >= 32 && ch.codeUnitAt(0) < 127) {
      if (ch != ' ' || buf.isNotEmpty) {
        buf += ch;
        if (echo) {
          addch(ch);
        }
      }
    }
    if ((ch == '\b' || ch == '\x7f') && buf.isNotEmpty) {
      buf = buf.substring(0, buf.length - 1);
      if (echo) {
        addch('\b');
        addch(' ');
        addch('\b');
      }
    }
    refresh();
  }
  checkMessage();
  return buf.trimRight();
}

void slurp() {
  // todo doesn't work
  //while (true) {
  //    getchar();
  //}
}
