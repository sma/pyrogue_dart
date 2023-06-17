import 'dart:io';

const COLS = 80;
const LINES = 24;

final _screen = List.generate(LINES, (_) => List.generate(COLS, (_) => (false, ' ')));
var _cx = 0;
var _cy = 0;
var _standout = false;

var _oldLineMode = false;
var _oldEchoMode = false;
var _oldEchoNewlineMode = false;

final _log = <String>[];

void log(String message) => _log.add(message);

void initscr() {
  if (stdin.hasTerminal) {
    _oldLineMode = stdin.lineMode;
    _oldEchoMode = stdin.echoMode;
    _oldEchoNewlineMode = stdin.echoNewlineMode;
  }
  clear();
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
  if (!stdin.hasTerminal) return;
  stdin.echoNewlineMode = false;
}

void endwin() {
  if (stdin.hasTerminal) {
    stdin.lineMode = _oldLineMode;
    stdin.echoMode = _oldEchoMode;
    stdin.echoNewlineMode = _oldEchoNewlineMode;
  }
}

void beep() {
  stdout.write('\x07');
}

void clear() {
  _standout = false;
  for (var row = 0; row < LINES; row++) {
    for (var col = 0; col < COLS; col++) {
      _screen[row][col] = (_standout, ' ');
    }
  }
}

void clrtoeol() {
  if (_cy < 0 || _cy >= LINES) return;
  for (var col = _cx; col < COLS; col++) {
    _screen[_cy][col] = (_standout, ' ');
  }
}

String getchar() {
  return String.fromCharCode(stdin.readByteSync());
}

void move(int row, int col) {
  _cy = row;
  _cx = col;
}

void mvaddch(int row, int col, String ch) {
  move(row, col);
  addch(ch);
}

void mvaddstr(int row, int col, String s) {
  move(row, col);
  addstr(s);
}

String mvinch(int row, int col) {
  return _screen[row][col].$2;
}

void refresh() {
  var standout = false;
  final buf = StringBuffer();
  if (stdout.supportsAnsiEscapes) {
    buf.write('\x1b[H\x1b[2J');
  } else {
    buf.write('\n' * LINES);
  }
  for (final line in _screen) {
    for (final (st, ch) in line) {
      if (stdout.supportsAnsiEscapes && st != standout) {
        if (st) {
          buf.write('\x1B[7m');
        } else {
          buf.write('\x1B[m');
        }
        standout = st;
      }
      buf.write(ch);
    }
    if (COLS < stdout.terminalColumns) {
      buf.write('\n');
    }
  }
  if (_log.isNotEmpty) buf.write('\x1b[${LINES + 1};1H\x1b[2m> ${_log.join('\n> ')}\x1b[m');
  if (stdout.supportsAnsiEscapes) {
    buf.write('\x1b[${_cy + 1};${_cx + 1}H');
  }
  stdout.write(buf);
}

void standout() {
  _standout = true;
}

void standend() {
  _standout = false;
}

void addch(String ch) {
  assert(ch.length == 1);
  if (ch == '\n') {
    _cx = 0;
    _cy++;
  } else {
    if (_cy >= 0 && _cy < LINES && _cx >= 0 && _cx < COLS) {
      _screen[_cy][_cx] = (_standout, ch);
    }
    if (++_cx == COLS) {
      _cx = 0;
      _cy++;
    }
  }
}

void addstr(String s) {
  for (var i = 0; i < s.length; i++) {
    addch(s[i]);
  }
}
