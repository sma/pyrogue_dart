import 'dart:io';

const COLS = 80;
const LINES = 24;

var _oldLineMode = false;
var _oldEchoMode = false;

void initscr() {
  if (stdin.hasTerminal) {
    _oldLineMode = stdin.lineMode;
    _oldEchoMode = stdin.echoMode;
  }
}

void crmode() {
  if (!stdin.hasTerminal) return;
  stdin.lineMode = false;
  stdin.echoMode = false;
}

void noecho() {
  if (!stdin.hasTerminal) return;
  stdin.echoMode = false;
}

void nonl() {
  // No implementation needed in Dart using dart:io.
}

void endwin() {
  if (stdin.hasTerminal) {
    stdin.lineMode = _oldLineMode;
    stdin.echoMode = _oldEchoMode;
  }
}

void beep() {
  stdout.write('\x07');
}

void clear() {
  stdout.write('\x1B[2J');
}

void clrtoeol() {
  stdout.write('\x1B[K');
}

String getchar() {
  return String.fromCharCode(stdin.readByteSync());
}

void move(int row, int col) {
  stdout.write('\x1B[${row + 1};${col + 1}H');
}

void mvaddch(int row, int col, String ch) {
  move(row, col);
  stdout.write(ch);
}

void mvaddstr(int row, int col, String s) {
  move(row, col);
  stdout.write(s);
}

String mvinch(int row, int col) {
  move(row, col);
  return String.fromCharCode(stdin.readByteSync());
}

void refresh() {
  // No implementation needed in Dart using dart:io.
}

void standout() {
  stdout.write('\x1B[7m');
}

void standend() {
  stdout.write('\x1B[27m');
}

void addch(String ch) {
  stdout.write(ch);
}

void addstr(String s) {
  stdout.write(s);
}
