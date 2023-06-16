import 'globals.dart';

void message(String msg, [int intrpt = 0]) {
  if (intrpt != 0) {
    g.interrupted = 1;
  }
  g.cantInt = 1;
  slurp();

  if (g.messageCleared == false) {
    mvaddstr(MIN_ROW - 1, g.messageCol, MORE);
    refresh();
    wait_for_ack("");
    check_message();
  }

  g.messageLine = msg;
  mvaddstr(MIN_ROW - 1, 0, msg);
  addch(' ');
  refresh();
  g.messageCleared = false;
  g.messageCol = msg.length;

  if (g.didInt != 0) {
    onintr();
  }
  g.cantInt = 0;
}

void remessage() {
  if (g.messageLine != null) {
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

void get_input_line(StringBuffer buf, int if_cancelled) {
  throw UnimplementedError();
}

void slurp() {
  // todo doesn't work
  //while (true) {
  //    getchar();
  //}
}