import 'globals.dart';

void lightUpRoom() {
  if (g.blind > 0) return;
  final r = rooms[g.currentRoom];
  for (var i = r.topRow; i <= r.bottomRow; i++) {
    for (var j = r.leftCol; j <= r.rightCol; j++) {
      mvaddch(i, j, getRoomChar(screen[i][j], i, j));
    }
  }
  mvaddch(rogue.row, rogue.col, rogue.fchar);
}

void lightPassage(int row, int col) {
  if (g.blind > 0) return;
  final iEnd = row < LINES - 2 ? 1 : 0;
  final jEnd = col < COLS - 1 ? 1 : 0;

  for (var i = row > MIN_ROW ? -1 : 0; i <= iEnd; i++) {
    for (var j = col > 0 ? -1 : 0; j <= jEnd; j++) {
      if (isPassable(row + i, col + j)) {
        final r = row + i;
        final c = col + j;
        mvaddch(r, c, getRoomChar(screen[r][c], r, c));
      }
    }
  }
}

void darkenRoom(int rn) {
  if (g.blind > 0) return;
  final r = rooms[rn];
  for (var i = r.topRow + 1; i < r.bottomRow; i++) {
    for (var j = r.leftCol + 1; j < r.rightCol; j++) {
      if (!isObject(i, j) && !(g.detectMonster && (screen[i][j] & MONSTER) != 0)) {
        if (!hidingXeroc(i, j)) {
          mvaddch(i, j, ' ');
        }
      }
    }
  }
}

String getRoomChar(int mask, int row, int col) {
  if ((mask & MONSTER) != 0) {
    return getMonsterCharRowCol(row, col);
  }
  if ((mask & SCROLL) != 0) {
    return '?';
  }
  if ((mask & POTION) != 0) {
    return '!';
  }
  if ((mask & FOOD) != 0) {
    return ':';
  }
  if ((mask & WAND) != 0) {
    return '/';
  }
  if ((mask & ARMOR) != 0) {
    return ']';
  }
  if ((mask & WEAPON) != 0) {
    return ')';
  }
  if ((mask & GOLD) != 0) {
    return '*';
  }
  if ((mask & TUNNEL) != 0) {
    return '#';
  }
  if ((mask & HORWALL) != 0) {
    return '-';
  }
  if ((mask & VERTWALL) != 0) {
    return '|';
  }
  if ((mask & AMULET) != 0) {
    return ',';
  }
  if ((mask & FLOOR) != 0) {
    return '.';
  }
  if ((mask & DOOR) != 0) {
    return '+';
  }
  if ((mask & STAIRS) != 0) {
    return '%';
  }
  return ' ';
}

(int, int) getRandRowCol(int mask) {
  while (true) {
    final row = getRand(MIN_ROW, SROWS - 2);
    final col = getRand(0, SCOLS - 1);
    final rn = getRoomNumber(row, col);
    if ((screen[row][col] & mask) != 0 && (screen[row][col] & ~mask) == 0 && rn != NO_ROOM) {
      return (row, col);
    }
  }
}

int getRandRoom() {
  while (true) {
    final i = getRand(0, MAXROOMS - 1);
    if (rooms[i].isRoom) {
      return i;
    }
  }
}

int fillRoomWithObjects(int rn) {
  final r = rooms[rn];
  final N = (r.bottomRow - r.topRow - 1) * (r.rightCol - r.leftCol - 1);
  var n = getRand(5, 10);
  if (n > N) n = N - 2;

  for (var i = 0; i < n; i++) {
    int row;
    int col;
    while (true) {
      row = getRand(r.topRow + 1, r.bottomRow - 1);
      col = getRand(r.leftCol + 1, r.rightCol - 1);
      if (screen[row][col] == FLOOR) break;
    }
    final obj = getRandObject();
    putObjectAt(obj, row, col);
  }

  return n;
}

int getRoomNumber(int row, int col) {
  for (var i = 0; i < MAXROOMS; i++) {
    final r = rooms[i];
    if (r.topRow <= row && row <= r.bottomRow && r.leftCol <= col && col <= r.rightCol) {
      return i;
    }
  }
  return NO_ROOM;
}

void shell() {
  throw Exception();
}
