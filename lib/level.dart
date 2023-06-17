import 'globals.dart';

var levelPoints = [
  10,
  20,
  40,
  80,
  160,
  320,
  640,
  1300,
  2600,
  5200,
  10000,
  20000,
  40000,
  80000,
  160000,
  320000,
  1000000,
  10000000,
];

void makeLevel() {
  g.partyRoom = -1;
  if (g.currentLevel < 126) {
    g.currentLevel += 1;
  }
  if (g.currentLevel > g.maxLevel) {
    g.maxLevel = g.currentLevel;
  }

  int mustExists1;
  int mustExists2;
  if (randPercent(50)) {
    mustExists1 = 1;
    mustExists2 = 7;
  } else {
    mustExists1 = 3;
    mustExists2 = 5;
  }

  for (int i = 0; i < MAXROOMS; i++) {
    makeRoom(i, mustExists1, mustExists2, 4);
  }

  tryRooms(0, 1, 2);
  tryRooms(0, 3, 6);
  tryRooms(2, 5, 8);
  tryRooms(6, 7, 8);

  for (int i = 0; i < MAXROOMS - 1; i++) {
    connectRooms(i, i + 1, mustExists1, mustExists2, 4);
    if (i < MAXROOMS - 3) {
      connectRooms(i, i + 3, mustExists1, mustExists2, 4);
    }
  }
  addDeadEnds();

  if (!g.hasAmulet && g.currentLevel >= AMULET_LEVEL) {
    putAmulet();
  }
}

void makeRoom(int n, int r1, int r2, int r3) {
  int leftCol;
  int rightCol;
  int topRow;
  int bottomRow;

  switch (n) {
    case 0:
      leftCol = 0;
      rightCol = COL1 - 1;
      topRow = MIN_ROW;
      bottomRow = ROW1 - 1;
      break;
    case 1:
      leftCol = COL1 + 1;
      rightCol = COL2 - 1;
      topRow = MIN_ROW;
      bottomRow = ROW1 - 1;
      break;
    case 2:
      leftCol = COL2 + 1;
      rightCol = COLS - 1;
      topRow = MIN_ROW;
      bottomRow = ROW1 - 1;
      break;
    case 3:
      leftCol = 0;
      rightCol = COL1 - 1;
      topRow = ROW1 + 1;
      bottomRow = ROW2 - 1;
      break;
    case 4:
      leftCol = COL1 + 1;
      rightCol = COL2 - 1;
      topRow = ROW1 + 1;
      bottomRow = ROW2 - 1;
      break;
    case 5:
      leftCol = COL2 + 1;
      rightCol = COLS - 1;
      topRow = ROW1 + 1;
      bottomRow = ROW2 - 1;
      break;
    case 6:
      leftCol = 0;
      rightCol = COL1 - 1;
      topRow = ROW2 + 1;
      bottomRow = LINES - 2;
      break;
    case 7:
      leftCol = COL1 + 1;
      rightCol = COL2 - 1;
      topRow = ROW2 + 1;
      bottomRow = LINES - 2;
      break;
    case 8:
      leftCol = COL2 + 1;
      rightCol = COLS - 1;
      topRow = ROW2 + 1;
      bottomRow = LINES - 2;
      break;
    default:
      throw Error();
  }

  if (!(n != r1 && n != r2 && n != r3 && randPercent(45))) {
    int height = getRand(4, bottomRow - topRow + 1);
    int width = getRand(7, rightCol - leftCol - 2);
    int rowOffset = getRand(0, bottomRow - topRow - height + 1);
    int colOffset = getRand(0, rightCol - leftCol - width + 1);

    topRow += rowOffset;
    bottomRow = topRow + height - 1;
    leftCol += colOffset;
    rightCol = leftCol + width - 1;

    rooms[n].isRoom = true;
    for (int i = topRow; i <= bottomRow; i++) {
      for (int j = leftCol; j <= rightCol; j++) {
        int ch;
        if (i == topRow || i == bottomRow) {
          ch = HORWALL;
        } else if (j == leftCol || j == rightCol) {
          ch = VERTWALL;
        } else {
          ch = FLOOR;
        }
        addMask(i, j, ch);
      }
    }

    rooms[n].topRow = topRow;
    rooms[n].bottomRow = bottomRow;
    rooms[n].leftCol = leftCol;
    rooms[n].rightCol = rightCol;
    rooms[n].height = height;
    rooms[n].width = width;
  }
}

void connectRooms(int room1, int room2, int m1, int m2, int m3) {
  if (room1 != m1 && room1 != m2 && room1 != m3 && room2 != m1 && room2 != m2 && room2 != m3) {
    if (randPercent(80)) return;
  }
  if (adjascent(room1, room2)) {
    doConnect(room1, room2);
  }
}

void doConnect(int room1, int room2) {
  int dir1;
  int dir2;

  if (rooms[room1].leftCol > rooms[room2].rightCol && onSameRow(room1, room2)) {
    dir1 = LEFT;
    dir2 = RIGHT;
  } else if (rooms[room2].leftCol > rooms[room1].rightCol && onSameRow(room1, room2)) {
    dir1 = RIGHT;
    dir2 = LEFT;
  } else if (rooms[room1].topRow > rooms[room2].bottomRow && onSameCol(room1, room2)) {
    dir1 = UP;
    dir2 = DOWN;
  } else if (rooms[room2].topRow > rooms[room1].bottomRow && onSameCol(room1, room2)) {
    dir1 = DOWN;
    dir2 = UP;
  } else {
    return;
  }

  final (row1, col1) = putDoor(room1, dir1);
  final (row2, col2) = putDoor(room2, dir2);
  drawSimplePassage(row1, col1, row2, col2, dir1);
  if (randPercent(10)) {
    drawSimplePassage(row1, col1, row2, col2, dir1);
  }

  rooms[room1].doors[dir1 ~/ 2].otherRoom = room2;
  rooms[room1].doors[dir1 ~/ 2].otherRow = row2;
  rooms[room1].doors[dir1 ~/ 2].otherCol = col2;

  rooms[room1].doors[dir2 ~/ 2].otherRoom = room1;
  rooms[room1].doors[dir2 ~/ 2].otherRow = row1;
  rooms[room1].doors[dir2 ~/ 2].otherCol = col1;
}

void clearLevel() {
  for (int i = 0; i < MAXROOMS; i++) {
    rooms[i].isRoom = false;
    for (int j = 0; j < 4; j++) {
      rooms[i].doors[j].otherRoom = NO_ROOM;
    }
  }
  for (int i = 0; i < SROWS; i++) {
    for (int j = 0; j < SCOLS; j++) {
      screen[i][j] = BLANK;
    }
  }
  g.detectMonster = false;
  g.beingHeld = false;
}

void printStats() {
  var m =
      "Level: ${g.currentLevel}  Gold: ${rogue.gold}  Hp: ${rogue.hpCurrent}(${rogue.hpMax})  Str: ${rogue.strengthCurrent}(${rogue.strengthMax})  Arm: ${getArmorClass(rogue.armor)}  Exp: ${rogue.exp}/${rogue.expPoints} ${g.hungerStr}";

  mvaddstr(LINES - 1, 0, m);
  clrtoeol();
  refresh();
}

void addMask(int row, int col, int mask) {
  if (mask == DOOR) {
    removeMask(row, col, HORWALL);
    removeMask(row, col, VERTWALL);
  }
  screen[row][col] |= mask;
}

void removeMask(int row, int col, int mask) {
  screen[row][col] &= ~mask;
}

bool adjascent(int room1, int room2) {
  if (!rooms[room1].isRoom || !rooms[room2].isRoom) {
    return false;
  }
  if (room1 > room2) {
    (room1, room2) = (room2, room1);
  }
  return (onSameCol(room1, room2) || onSameRow(room1, room2)) && (room2 - room1 == 1 || room2 - room1 == 3);
}

(int, int) putDoor(int rn, int dir) {
  int row;
  int col;
  switch (dir) {
    case UP:
    case DOWN:
      row = (dir == UP) ? rooms[rn].topRow : rooms[rn].bottomRow;
      col = getRand(rooms[rn].leftCol + 1, rooms[rn].rightCol - 1);
      break;
    case LEFT:
    case RIGHT:
      row = getRand(rooms[rn].topRow + 1, rooms[rn].bottomRow - 1);
      col = (dir == LEFT) ? rooms[rn].leftCol : rooms[rn].rightCol;
      break;
    default:
      throw Error();
  }
  addMask(row, col, DOOR);
  return (row, col);
}

void drawSimplePassage(int row1, int col1, int row2, int col2, int dir) {
  if (dir == LEFT || dir == RIGHT) {
    if (col2 < col1) {
      (row1, row2) = (row2, row1);
      (col1, col2) = (col2, col1);
    }
    int middle = getRand(col1 + 1, col2 - 1);
    for (int i = col1 + 1; i < middle; i++) {
      addMask(row1, i, TUNNEL);
    }
    for (int i = row1; i != row2; i += (row1 > row2) ? -1 : 1) {
      addMask(i, middle, TUNNEL);
    }
    for (int i = middle; i < col2; i++) {
      addMask(row2, i, TUNNEL);
    }
  } else {
    if (row2 < row1) {
      (row1, row2) = (row2, row1);
      (col1, col2) = (col2, col1);
    }
    int middle = getRand(row1 + 1, row2 - 1);
    for (int i = row1 + 1; i < middle; i++) {
      addMask(i, col1, TUNNEL);
    }
    for (int i = col1; i != col2; i += (col1 > col2) ? -1 : 1) {
      addMask(middle, i, TUNNEL);
    }
    for (int i = middle; i < row2; i++) {
      addMask(i, col2, TUNNEL);
    }
  }
}

bool onSameRow(int room1, int room2) {
  return room1 ~/ 3 == room2 ~/ 3;
}

bool onSameCol(int room1, int room2) {
  return room1 % 3 == room2 % 3;
}

void addDeadEnds() {
  if (g.currentLevel <= 2) {
    return;
  }

  int start = getRand(0, MAXROOMS - 1);
  int deadEndPercent = 12 + g.currentLevel * 2;

  for (int i = 0; i < MAXROOMS; i++) {
    int j = (start + i) % MAXROOMS;

    if (rooms[j].isRoom) {
      continue;
    }

    if (!randPercent(deadEndPercent)) {
      continue;
    }

    int row = rooms[j].topRow + getRand(0, 6);
    int col = rooms[j].leftCol + getRand(0, 19);

    bool found = false;
    while (!found) {
      int distance = getRand(8, 20);
      int dir = getRand(0, 3) * 2;
      int j = 0;
      while (j < distance && !found) {
        if (dir == UP) {
          if (row - 1 >= MIN_ROW) row -= 1;
        } else if (dir == RIGHT) {
          if (col + 1 < COLS - 1) col += 1;
        } else if (dir == DOWN) {
          if (row + 1 < LINES - 2) row += 1;
        } else if (dir == LEFT) {
          if (col - 1 > 0) col -= 1;
        }
        if ((screen[row][col] & (VERTWALL | HORWALL | DOOR)) != 0) {
          breakIn(row, col, screen[row][col], dir);
          found = true;
        } else {
          addMask(row, col, TUNNEL);
        }
        j += 1;
      }
    }
  }
}

void breakIn(int row, int col, int ch, int dir) {
  if (ch == DOOR) {
    return;
  }
  int rn = getRoomNumber(row, col);

  if (ch == VERTWALL) {
    if (col == rooms[rn].leftCol) {
      if (rooms[rn].doors[LEFT ~/ 2].otherRoom != NO_ROOM) {
        int drow = doorRow(rn, LEFT);
        for (int i = row; i < drow; i++) {
          addMask(i, col - 1, TUNNEL);
        }
      } else {
        rooms[rn].doors[LEFT ~/ 2].otherRoom = DEAD_END;
        addMask(row, col, DOOR);
      }
    } else {
      if (rooms[rn].doors[RIGHT ~/ 2].otherRoom != NO_ROOM) {
        int drow = doorRow(rn, RIGHT);
        for (int i = row; i < drow; i++) {
          addMask(i, col + 1, TUNNEL);
        }
      } else {
        rooms[rn].doors[RIGHT ~/ 2].otherRoom = DEAD_END;
        addMask(row, col, DOOR);
      }
    }
  } else {
    if (col == rooms[rn].leftCol) {
      if (row == MIN_ROW) {
        addMask(row + 1, col - 1, TUNNEL);
        breakIn(row + 1, col, VERTWALL, RIGHT);
      } else if (row == LINES - 2) {
        addMask(row - 1, col - 1, TUNNEL);
        breakIn(row - 1, col, VERTWALL, RIGHT);
      } else {
        if (row == rooms[rn].topRow) {
          if (dir == RIGHT) {
            addMask(row - 1, col - 1, TUNNEL);
            addMask(row - 1, col, TUNNEL);
          }
          addMask(row - 1, col + 1, TUNNEL);
          breakIn(row, col + 1, HORWALL, DOWN);
        } else {
          if (dir == RIGHT) {
            addMask(row + 1, col - 1, TUNNEL);
            addMask(row + 1, col, TUNNEL);
          }
          addMask(row + 1, col + 1, TUNNEL);
          breakIn(row, col + 1, HORWALL, UP);
        }
        return;
      }
    } else if (col == rooms[rn].rightCol) {
      if (row == MIN_ROW) {
        addMask(row + 1, col + 1, TUNNEL);
        breakIn(row + 1, col, VERTWALL, LEFT);
      } else if (row == LINES - 2) {
        addMask(row - 1, col + 1, TUNNEL);
        breakIn(row - 1, col, VERTWALL, LEFT);
      } else {
        if (row == rooms[rn].topRow) {
          if (dir == DOWN) {
            addMask(row - 1, col + 1, TUNNEL);
            addMask(row, col + 1, TUNNEL);
          }
          addMask(row + 1, col + 1, TUNNEL);
          breakIn(row + 1, col, VERTWALL, LEFT);
        } else {
          if (dir == UP) {
            addMask(row + 1, col + 1, TUNNEL);
            addMask(row, col + 1, TUNNEL);
          }
          addMask(row - 1, col + 1, TUNNEL);
          breakIn(row - 1, col, VERTWALL, LEFT);
        }
        return;
      }
    }
    if (row == rooms[rn].topRow) {
      if (rooms[rn].doors[UP ~/ 2].otherRoom != NO_ROOM) {
        int dcol = doorCol(rn, UP);
        for (int i = col; i < dcol; i++) {
          addMask(row - 1, i, TUNNEL);
        }
      } else {
        rooms[rn].doors[UP ~/ 2].otherRoom = DEAD_END;
        addMask(row, col, DOOR);
      }
    } else {
      if (rooms[rn].doors[DOWN ~/ 2].otherRoom != NO_ROOM) {
        int dcol = doorCol(rn, DOWN);
        for (int i = col; i < dcol; i++) {
          addMask(row + 1, i, TUNNEL);
        }
      } else {
        rooms[rn].doors[DOWN ~/ 2].otherRoom = DEAD_END;
        addMask(row, col, DOOR);
      }
    }
  }
}

int doorRow(int rn, int dir) {
  if (rooms[rn].doors[dir ~/ 2].otherRoom == NO_ROOM) {
    return -1;
  }

  int col = (dir == LEFT) ? rooms[rn].leftCol : rooms[rn].rightCol;
  for (int row = rooms[rn].topRow; row < rooms[rn].bottomRow; row++) {
    if ((screen[row][col] & DOOR) != 0) {
      return row;
    }
  }
  return -1;
}

int doorCol(int rn, int dir) {
  if (rooms[rn].doors[dir ~/ 2].otherRoom == NO_ROOM) {
    return -1;
  }
  int row = (dir == UP) ? rooms[rn].topRow : rooms[rn].bottomRow;
  for (int col = rooms[rn].leftCol; col < rooms[rn].rightCol; col++) {
    if ((screen[row][col] & DOOR) != 0) {
      return col;
    }
  }
  return -1;
}

void putPlayer() {
  while (true) {
    var (row, col) = getRandRowCol(FLOOR | IS_OBJECT);
    g.currentRoom = getRoomNumber(row, col);
    if (g.currentRoom != g.partyRoom) {
      rogue.row = row;
      rogue.col = col;
      break;
    }
  }
}

bool checkDown() {
  if ((screen[rogue.row][rogue.col] & STAIRS) != 0) {
    return true;
  }
  message("I see no way down", 0);
  return false;
}

bool checkUp() {
  if ((screen[rogue.row][rogue.col] & STAIRS) == 0) {
    message("I see no way up", 0);
    return false;
  }
  if (!g.hasAmulet) {
    message("your way is magically blocked", 0);
    return false;
  }
  if (g.currentLevel == 1) {
    win();
    return true;
  } else {
    g.currentLevel -= 2;
    return true;
  }
}

void addExp(int e) {
  rogue.expPoints += e;

  if (rogue.expPoints >= levelPoints[rogue.exp - 1]) {
    int newExp = getExpLevel(rogue.expPoints);
    for (int i = rogue.exp + 1; i <= newExp; i++) {
      message("welcome to level $i", 0);
      int hp = getRand(3, 10);
      rogue.hpCurrent += hp;
      rogue.hpMax += hp;
      printStats();
    }
    rogue.exp = newExp;
  }
  printStats();
}

int getExpLevel(int e) {
  for (int i = 0; i < 50; i++) {
    if (levelPoints[i] > e) {
      return i + 1;
    }
  }
  return 50;
}

void tryRooms(int r1, int r2, int r3) {
  if (rooms[r1].isRoom && !rooms[r2].isRoom && rooms[r3].isRoom) {
    if (randPercent(75)) {
      doConnect(r1, r3);
    }
  }
}
