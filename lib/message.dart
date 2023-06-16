void message(String msg, [int intrpt = 0]) {
  if (intrpt != 0) {
    g.interrupted = 1;
  }
  g.cant_int = 1;
  slurp();

  if (g.message_cleared == false) {
    mvaddstr(MIN_ROW - 1, g.message_col, MORE);
    refresh();
    wait_for_ack("");
    check_message();
  }

  g.message_line = msg;
  mvaddstr(MIN_ROW - 1, 0, msg);
  addch(' ');
  refresh();
  g.message_cleared = false;
  g.message_col = msg.length;

  if (g.did_int != 0) {
    onintr();
  }
  g.cant_int = 0;
}

void remessage() {
  if (g.message_line != null) {
    message(g.message_line, 0);
  }
}

void check_message() {
  if (g.message_cleared) {
    return;
  }
  move(MIN_ROW - 1, 0);
  clrtoeol();
  move(rogue.row, rogue.col);
  refresh();
  g.message_cleared = true;
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