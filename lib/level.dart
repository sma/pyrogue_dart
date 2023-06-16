import 'globals.dart';

var level_points = [
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
  g.party_room = -1;
  if (g.current_level < 126) {
    g.current_level += 1;
  }
  if (g.current_level > g.max_level) {
    g.max_level = g.current_level;
  }

  int must_exists1;
  int must_exists2;
  if (randPercent(50)) {
    must_exists1 = 1;
    must_exists2 = 7;
  } else {
    must_exists1 = 3;
    must_exists2 = 5;
  }

  for (int i = 0; i < MAXROOMS; i++) {
    makeRoom(i, must_exists1, must_exists2, 4);
  }

  tryRooms(0, 1, 2);
  tryRooms(0, 3, 6);
  tryRooms(2, 5, 8);
  tryRooms(6, 7, 8);

  for (int i = 0; i < MAXROOMS - 1; i++) {
    connectRooms(i, i + 1, must_exists1, must_exists2, 4);
    if (i < MAXROOMS - 3) {
      connectRooms(i, i + 3, must_exists1, must_exists2, 4);
    }
  }
  addDeadEnds();

  if (!g.has_amulet && g.current_level >= AMULET_LEVEL) {
    putAmulet();
  }
}

void makeRoom(int n, int r1, int r2, int r3) {
  int left_col;
  int right_col;
  int top_row;
  int bottom_row;

  switch (n) {
    case 0:
      left_col = 0;
      right_col = COL1 - 1;
      top_row = MIN_ROW;
      bottom_row = ROW1 - 1;
      break;
    case 1:
      left_col = COL1 + 1;
      right_col = COL2 - 1;
      top_row = MIN_ROW;
      bottom_row = ROW1 - 1;
      break;
    case 2:
      left_col = COL2 + 1;
      right_col = COLS - 1;
      top_row = MIN_ROW;
      bottom_row = ROW1 - 1;
      break;
    case 3:
      left_col = 0;
      right_col = COL1 - 1;
      top_row = ROW1 + 1;
      bottom_row = ROW2 - 1;
      break;
    case 4:
      left_col = COL1 + 1;
      right_col = COL2 - 1;
      top_row = ROW1 + 1;
      bottom_row = ROW2 - 1;
      break;
    case 5:
      left_col = COL2 + 1;
      right_col = COLS - 1;
      top_row = ROW1 + 1;
      bottom_row = ROW2 - 1;
      break;
    case 6:
      left_col = 0;
      right_col = COL1 - 1;
      top_row = ROW2 + 1;
      bottom_row = LINES - 2;
      break;
   

 case 7:
      left_col = COL1 + 1;
      right_col = COL2 - 1;
      top_row = ROW2 + 1;
      bottom_row = LINES - 2;
      break;
    case 8:
      left_col = COL2 + 1;
      right_col = COLS - 1;
      top_row = ROW2 + 1;
      bottom_row = LINES - 2;
      break;
    default:
      assert(false);
  }

  if (!(n != r1 && n != r2 && n != r3 && randPercent(45))) {
    int height = getRand(4, bottom_row - top_row + 1);
    int width = getRand(7, right_col - left_col - 2);
    int row_offset = getRand(0, bottom_row - top_row - height + 1);
    int col_offset = getRand(0, right_col - left_col - width + 1);

    top_row += row_offset;
    bottom_row = top_row + height - 1;
    left_col += col_offset;
    right_col = left_col + width - 1;

    rooms[n].is_room = true;
    for (int i = top_row; i <= bottom_row; i++) {
      for (int j = left_col; j <= right_col; j++) {
        int ch;
        if (i == top_row || i == bottom_row) {
          ch = HORWALL;
        } else if (j == left_col || j == right_col) {
          ch = VERTWALL;
        } else {
          ch = FLOOR;
        }
        addMask(i, j, ch);
      }
    }

    rooms[n].top_row = top_row;
    rooms[n].bottom_row = bottom_row;
    rooms[n].left_col = left_col;
    rooms[n].right_col = right_col;
    rooms[n].height = height;
    rooms[n].width = width;
  }
}

void connectRooms(int room1, int room2, int m1, int m2, int m3) {
  if (!(room1 != m1 && room1 != m2 && room1 != m3 && room2 != m1 && room2 != m2 && room2 != m3) ||
      adjascent(room1, room2)) {
    doConnect(room1, room2);
  }
}

void doConnect(int room1, int room2) {
  int dir1;
  int dir2;

  if (rooms[room1].left_col > rooms[room2].right_col && onSameRow(room1, room2)) {
    dir1 = LEFT;
    dir2 = RIGHT;
  } else if (rooms[room2].left_col > rooms[room1].right_col && onSameRow(room1, room2)) {
    dir1 = RIGHT;
    dir2 = LEFT;
  } else if (rooms[room1].top_row > rooms[room2].bottom_row && onSameCol(room1, room2)) {
    dir1 = UP;
    dir2 = DOWN;
  } else if (rooms[room2].top_row > rooms[room1].bottom_row && onSameCol(room1, room2)) {
    dir1 = DOWN;
    dir2 = UP;
  } else {
    return;
  }

  int row1, col1;
  int row2, col2;
  var putDoor = putDoor;

  putDoor(room1, dir1, (int r, int c) {
    row1 = r;
    col1 = c;
  });
  putDoor(room2

, dir2, (int r, int c) {
    row2 = r;
    col2 = c;
  });

  drawSimplePassage(row1, col1, row2, col2, dir1);
  if (randPercent(10)) {
    drawSimplePassage(row1, col1, row2, col2, dir1);
  }

  rooms[room1].doors[dir1 ~/ 2].other_room = room2;
  rooms[room1].doors[dir1 ~/ 2].other_row = row2;
  rooms[room1].doors[dir1 ~/ 2].other_col = col2;

  rooms[room1].doors[dir2 ~/ 2].other_room = room1;
  rooms[room1].doors[dir2 ~/ 2].other_row = row1;
  rooms[room1].doors[dir2 ~/ 2].other_col = col1;
}

void clearLevel() {
  for (int i = 0; i < MAXROOMS; i++) {
    rooms[i].is_room = false;
    for (int j = 0; j < 4; j++) {
      rooms[i].doors[j].other_room = NO_ROOM;
    }
  }
  for (int i = 0; i < SROWS; i++) {
    for (int j = 0; j < SCOLS; j++) {
      screen[i][j] = BLANK;
    }
  }
  g.detect_monster = 0;
  g.being_held = 0;
}

void printStats() {
  var m = "Level: ${g.current_level}  Gold: ${rogue.gold}  Hp: ${rogue.hp_current}(${rogue.hp_max})" +
      "  Str: ${rogue.strength_current}(${rogue.strength_max})  Arm: ${getArmorClass(rogue.armor)}" +
      "  Exp: ${rogue.exp}/${rogue.exp_points} ${g.hunger_str}";

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
  if (!rooms[room1].is_room || !rooms[room2].is_room) {
    return false;
  }
  if (room1 > room2) {
    room1 ^= room2;
    room2 ^= room1;
    room1 ^= room2;
  }
  return (onSameCol(room1, room2) || onSameRow(room1, room2)) && (room2 - room1 == 1 || room2 - room1 == 3);
}

void putDoor(int rn, int dir, void callback(int, int)) {
  int row;
  int col;
  switch (dir) {
    case UP:
    case DOWN:
      row = (dir == UP) ? rooms[rn].top_row : rooms[rn].bottom_row;
      col = getRand(rooms[rn].left_col + 1, rooms[rn].right_col - 1);
      break;
    case LEFT:
    case RIGHT:
      row = getRand(rooms[rn].top_row + 1, rooms[rn].bottom_row - 1

);
      col = (dir == LEFT) ? rooms[rn].left_col : rooms[rn].right_col;
      break;
    default:
      assert(false);
  }
  addMask(row, col, DOOR);
  callback(row, col);
}

void drawSimplePassage(int row1, int col1, int row2, int col2, int dir) {
  if (dir == LEFT || dir == RIGHT) {
    if (col2 < col1) {
      row1 ^= row2;
      row2 ^= row1;
      row1 ^= row2;
      col1 ^= col2;
      col2 ^= col1;
      col1 ^= col2;
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
      row1 ^= row2;
      row2 ^= row1;
      row1 ^= row2;
      col1 ^= col2;
      col2 ^= col1;
      col1 ^= col2;
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
  if (g.current_level <= 2) {
    return;
  }

  int start = getRand(0, MAXROOMS - 1);
  int dead_end_percent = 12 + g.current_level * 2;

  for (int i = 0; i < MAXROOMS; i++) {
    int j = (start + i) % MAXROOMS;

    if (rooms[j].is_room) {
      continue;
    }

    if (!randPercent(dead_end_percent)) {
      continue;
    }

    int row = rooms[j].top_row + getRand(0, 6);
    int col = rooms[j].left_col + getRand(0, 19);

    bool found = false;
    while (!found) {
      int distance = getRand(8, 20);
      int dir = getRand(0, 3) * 2;
      int j = 0;
      while (j < distance && !found) {
        if (dir == UP) {
          if (row - 1 >= MIN_ROW) row -= 1;
        } else if (dir == RIGHT) {
          if (col + 1 < COLS -

 1) col += 1;
        } else if (dir == DOWN) {
          if (row + 1 < LINES - 2) row += 1;
        } else if (dir == LEFT) {
          if (col - 1 > 0) col -= 1;
        }
        if (screen[row][col] & (VERTWALL | HORWALL | DOOR)) {
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
    if (col == rooms[rn].left_col) {
      if (rooms[rn].doors[LEFT ~/ 2].other_room != NO_ROOM) {
        int drow = doorRow(rn, LEFT);
        for (int i = row; i < drow; i++) {
          addMask(i, col - 1, TUNNEL);
        }
      } else {
        rooms[rn].doors[LEFT ~/ 2].other_room = DEAD_END;
        addMask(row, col, DOOR);
      }
    } else {
      if (rooms[rn].doors[RIGHT ~/ 2].other_room != NO_ROOM) {
        int drow = doorRow(rn, RIGHT);
        for (int i = row; i < drow; i++) {
          addMask(i, col + 1, TUNNEL);
        }
      } else {
        rooms[rn].doors[RIGHT ~/ 2].other_room = DEAD_END;
        addMask(row, col, DOOR);
      }
    }
  } else {
    if (col == rooms[rn].left_col) {
      if (row == MIN_ROW) {
        addMask(row + 1, col - 1, TUNNEL);
        breakIn(row + 1, col, VERTWALL, RIGHT);
      } else if (row == LINES - 2) {
        addMask(row - 1, col - 1, TUNNEL);
        breakIn(row - 1, col, VERTWALL, RIGHT);
      } else {
        if (row == rooms[rn].top_row) {
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
    } else if (col == rooms[rn].right_col) {
      if (row == MIN_ROW) {
        addMask(row + 1, col + 1, TUNNEL);
        breakIn(row + 1, col, VERTWALL, LEFT);
      } else if (row == LINES - 2) {
        addMask(row - 1

, col + 1, TUNNEL);
        breakIn(row - 1, col, VERTWALL, LEFT);
      } else {
        if (row == rooms[rn].top_row) {
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
    if (row == rooms[rn].top_row) {
      if (rooms[rn].doors[UP ~/ 2].other_room != NO_ROOM) {
        int dcol = doorCol(rn, UP);
        for (int i = col; i < dcol; i++) {
          addMask(row - 1, i, TUNNEL);
        }
      } else {
        rooms[rn].doors[UP ~/ 2].other_room = DEAD_END;
        addMask(row, col, DOOR);
      }
    } else {
      if (rooms[rn].doors[DOWN ~/ 2].other_room != NO_ROOM) {
        int dcol = doorCol(rn, DOWN);
        for (int i = col; i < dcol; i++) {
          addMask(row + 1, i, TUNNEL);
        }
      } else {
        rooms[rn].doors[DOWN ~/ 2].other_room = DEAD_END;
        addMask(row, col, DOOR);
      }
    }
  }
}

int doorRow(int rn, int dir) {
  if (rooms[rn].doors[dir ~/ 2].other_room == NO_ROOM) {
    return -1;
  }

  int col = (dir == LEFT) ? rooms[rn].left_col : rooms[rn].right_col;
  for (int row = rooms[rn].top_row; row < rooms[rn].bottom_row; row++) {
    if (screen[row][col] & DOOR) {
      return row;
    }
  }
  return -1;
}

int doorCol(int rn, int dir) {
  if (rooms[rn].doors[dir ~/ 2].other_room == NO_ROOM) {
    return -1;
  }
  int row = (dir == UP) ? rooms[rn].top_row : rooms[rn].bottom_row;
  for (int col = rooms[rn].left_col; col < rooms[rn].right_col; col++) {
    if (screen[row][col] & DOOR) {
      return col;
    }
  }
  return -1;
}

void putPlayer() {
  while (true) {
    var row_col = getRandRowCol(FLOOR | IS_OBJECT);
    int row = row_col[0];
    int col = row_col[1];
    g.current_room = getRoomNumber(row, col);
    if (g.current_room != g.party_room) {
      break;
    }
  }
}

bool checkDown() {
  if (screen[rogue.row][rogue.col] & STAIRS) {
    return true;
  }
  message("I see no way down",

 0);
  return false;
}

bool checkUp() {
  if (!(screen[rogue.row][rogue.col] & STAIRS)) {
    message("I see no way up", 0);
    return false;
  }
  if (!g.has_amulet) {
    message("your way is magically blocked", 0);
    return false;
  }
  if (g.current_level == 1) {
    win();
  } else {
    g.current_level -= 2;
    return true;
  }
}

void addExp(int e) {
  rogue.exp_points += e;

  if (rogue.exp_points >= level_points[rogue.exp - 1]) {
    int new_exp = getExpLevel(rogue.exp_points);
    for (int i = rogue.exp + 1; i <= new_exp; i++) {
      message("welcome to level " + i.toString(), 0);
      int hp = getRand(3, 10);
      rogue.hp_current += hp;
      rogue.hp_max += hp;
      printStats();
    }
    rogue.exp = new_exp;
  }
  printStats();
}

int getExpLevel(int e) {
  for (int i = 0; i < 50; i++) {
    if (level_points[i] > e) {
      return i + 1;
    }
  }
  return 50;
}

void tryRooms(int r1, int r2, int r3) {
  if (rooms[r1].is_room && !rooms[r2].is_room && rooms[r3].is_room) {
    if (randPercent(75)) {
      doConnect(r1, r3);
    }
  }
}
