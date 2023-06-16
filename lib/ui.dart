import 'dart:io';

const COLS = 80;
const LINES = 24;

void initscr() {
  // No implementation needed in Dart using dart:io.
}

void crmode() {
  stdin.lineMode = false;
  stdin.echoMode = false;
}

void noecho() {
  stdin.echoMode = false;
}

void nonl() {
  // No implementation needed in Dart using dart:io.
}

void endwin() {
  // No implementation needed in Dart using dart:io.
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
  return stdin.readByteSync().toString();
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
