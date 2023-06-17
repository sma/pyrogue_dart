import 'dart:math';

export 'hit.dart';
export 'init.dart';
export 'inventory.dart';
export 'level.dart';
export 'main.dart';
export 'message.dart';
export 'monster.dart';
export 'move.dart';
export 'object.dart';
export 'pack.dart';
export 'play.dart';
export 'room.dart';
export 'score.dart';
export 'special_hit.dart';
export 'throw.dart';
export 'ui.dart';
export 'use.dart';
export 'zap.dart';

// global constants and variables, without `g` prefix for convenience

// monster.h
const int MONSTERS = 26;

const int HASTED = 0x1;
const int SLOWED = 0x2;
const int IS_INVIS = 0x4;
const int IS_ASLEEP = 0x8;
const int WAKENS = 0x10;
const int WANDERS = 0x20;
const int FLIES = 0x40;
const int FLITS = 0x80;
const int CAN_GO = 0x100;

const int MAXMONSTER = 26;

const int WAKE_PERCENT = 45;
const int FLIT_PERCENT = 33;
const int PARTY_WAKE_PERCENT = 75;

const int XEROC1 = 16; // levels xeroc appears at
const int XEROC2 = 25;

const int HYPOTHERMIA = 1;
const int STARVATION = 2;
const int QUIT = 3;
const int WIN = 4;

// move.h
const int UP = 0;
const int UPRIGHT = 1;
const int RIGHT = 2;
const int RIGHTDOWN = 3;
const int DOWN = 4;
const int DOWNLEFT = 5;
const int LEFT = 6;
const int LEFTUP = 7;

const int ROW1 = 7;
const int ROW2 = 15;

const int COL1 = 26;
const int COL2 = 52;

const int MOVED = 0;
const int MOVE_FAILED = -1;
const int STOPPED_ON_SOMETHING = -2;
const String CANCEL = '\x1b';
const String LIST = '*';

const int HUNGRY = 300;
const int WEAK = 120;
const int FAINT = 20;
const int STARVE = 0;

const int MIN_ROW = 1;

// object.h
const int BLANK = 0x0;
const int ARMOR = 0x1;
const int WEAPON = 0x2;
const int SCROLL = 0x4;
const int POTION = 0x8;
const int GOLD = 0x10;
const int FOOD = 0x20;
const int WAND = 0x40;
const int STAIRS = 0x80;
const int AMULET = 0x100;
const int MONSTER = 0x200;
const int HORWALL = 0x400;
const int VERTWALL = 0x800;
const int DOOR = 0x1000;
const int FLOOR = 0x2000;
const int TUNNEL = 0x4000;
const int UNUSED = 0x8000;

const int IS_OBJECT = 0x1FF;
const int CAN_PICK_UP = 0x17F;

const int LEATHER = 0;
const int RING = 1;
const int SCALE = 2;
const int CHAIN = 3;
const int BANDED = 4;
const int SPLINT = 5;
const int PLATE = 6;
const int ARMORS = 7;

const int BOW = 0;
const int ARROW = 1;
const int SHURIKEN = 2;
const int MACE = 3;
const int LONG_SWORD = 4;
const int TWO_HANDED_SWORD = 5;
const int WEAPONS = 6;

const int MAX_PACK_COUNT = 24;

const int PROTECT_ARMOR = 0;
const int HOLD_MONSTER = 1;
const int ENCHANT_WEAPON = 2;
const int ENCHANT_ARMOR = 3;
const int IDENTIFY = 4;
const int TELEPORT = 5;
const int SLEEP = 6;
const int SCARE_MONSTER = 7;
const int REMOVE_CURSE = 8;
const int CREATE_MONSTER = 9;
const int AGGRAVATE_MONSTER = 10;
const int SCROLLS = 11;

const int INCREASE_STRENGTH = 0;
const int RESTORE_STRENGTH = 1;
const int HEALING = 2;
const int EXTRA_HEALING = 3;
const int POISON = 4;
const int RAISE_LEVEL = 5;
const int BLINDNESS = 6;
const int HALLUCINATION = 7;
const int DETECT_MONSTER = 8;
const int DETECT_OBJECTS = 9;
const int CONFUSION = 10;
const int POTIONS = 11;

const int TELEPORT_AWAY = 0;
const int SLOW_MONSTER = 1;
const int KILL_MONSTER = 2;
const int INVISIBILITY = 3;
const int POLYMORPH = 4;
const int HASTE_MONSTER = 5;
const int PUT_TO_SLEEP = 6;
const int DO_NOTHING = 7;
const int WANDS = 8;

const int UNIDENTIFIED = 0;
const int IDENTIFIED = 1;
const int CALLED = 2;

const int SROWS = 24;
const int SCOLS = 80;

const int MAX_TITLE_LENGTH = 30;
const String MORE = "-more-";
const int MAXSYLLABLES = 40;
const int MAXMETALS = 15;

const int GOLD_PERCENT = 46;

class Identity {
  final int value;
  String title;
  final String real;
  int idStatus;

  Identity(this.value, this.title, this.real, this.idStatus);
}

class Object extends ObjHolder {
  int mFlags;
  String damage;
  int quantity;
  String ichar;
  int killExp;
  int isProtected;
  int isCursed;
  int clasz;
  int identified;
  int whichKind;
  int row;
  int col;
  int damageEnchantment;
  int quiver;
  int trow;
  int tcol;
  int toHitEnchantment;
  int whatIs;
  int pickedUp;
  // Object? nextObject;

  Object(
    this.mFlags,
    this.damage,
    this.quantity,
    this.ichar,
    this.killExp,
    this.isProtected,
    this.isCursed,
    this.clasz,
    this.identified,
    this.whichKind,
  )   : row = 0,
        col = 0,
        damageEnchantment = 0,
        quiver = 0,
        trow = 0,
        tcol = 0,
        toHitEnchantment = 0,
        whatIs = 0,
        pickedUp = 0;
  // nextObject = null;

  Object copy() {
    return Object(
      mFlags,
      damage,
      quantity,
      ichar,
      killExp,
      isProtected,
      isCursed,
      clasz,
      identified,
      whichKind,
    );
  }
}

class ObjHolder {
  Object? nextObject;

  ObjHolder();
}

class Fighter {
  Object? armor;
  Object? weapon;
  int hpCurrent;
  int hpMax;
  int strengthCurrent;
  int strengthMax;
  final ObjHolder pack;
  int gold;
  int exp;
  int expPoints;
  int row;
  int col;
  final String fchar;
  int movesLeft;

  Fighter()
      : armor = null,
        weapon = null,
        hpCurrent = 12,
        hpMax = 12,
        strengthCurrent = 16,
        strengthMax = 16,
        pack = ObjHolder(),
        gold = 0,
        exp = 1,
        expPoints = 0,
        row = 0,
        col = 0,
        fchar = '@',
        movesLeft = 1200;
}

class Door {
  int otherRoom;
  int otherRow;
  int otherCol;

  Door(this.otherRoom, this.otherRow, this.otherCol);
}

class Room {
  int bottomRow;
  int rightCol;
  int leftCol;
  int topRow;
  int width;
  int height;
  List<Door> doors;
  bool isRoom;

  Room()
      : bottomRow = 0,
        rightCol = 0,
        leftCol = 0,
        topRow = 0,
        width = 0,
        height = 0,
        doors = List.generate(4, (_) => Door(0, 0, 0)),
        isRoom = false;
}

// room.h
const int MAXROOMS = 9;

const int NO_ROOM = -1;
const int DEAD_END = -2;
const int PASSAGE = -3;

const int AMULET_LEVEL = 26;

final List<String> monsterNames = [
  "aquatar",
  "bat",
  "centaur",
  "dragon",
  "emu",
  "venus fly-trap",
  "griffin",
  "hobgoblin",
  "ice monster",
  "jabberwock",
  "kestrel",
  "leprechaun",
  "medusa",
  "nymph",
  "orc",
  "phantom",
  "quasit",
  "rattlesnake",
  "snake",
  "troll",
  "black unicorn",
  "vampire",
  "wraith",
  "xeroc",
  "yeti",
  "zombie"
];

final List<Object> monsterTab = [
  Object(IS_ASLEEP | WAKENS | WANDERS, "0d0", 25, 'A', 20, 9, 18, 100, 0, 0),
  Object(IS_ASLEEP | WANDERS | FLITS, "1d3", 10, 'B', 2, 1, 8, 60, 0, 0),
  Object(IS_ASLEEP | WANDERS, "3d3/2d5", 30, 'C', 15, 7, 16, 85, 0, 10),
  Object(IS_ASLEEP | WAKENS, "4d5/3d9", 128, 'D', 5000, 21, 126, 100, 0, 90),
  Object(IS_ASLEEP, "0d0", 15, 'E', 5, 2, 11, 68, 0, 0),
  Object(0, "0d0", 32, 'F', 91, 12, 126, 80, 0, 0),
  Object(IS_ASLEEP | WAKENS | WANDERS | FLIES, "5d4/4d5", 92, 'G', 2000, 20, 126, 85, 0, 10),
  Object(IS_ASLEEP | WAKENS | WANDERS, "1d3/1d3", 17, 'H', 3, 1, 10, 67, 0, 0),
  Object(IS_ASLEEP, "0d0", 15, 'I', 5, 2, 11, 68, 0, 0),
  Object(IS_ASLEEP | WANDERS, "3d10/3d4", 125, 'J', 3000, 21, 126, 100, 0, 0),
  Object(IS_ASLEEP | WAKENS | WANDERS | FLIES, "1d4", 10, 'K', 2, 1, 6, 60, 0, 0),
  Object(IS_ASLEEP, "0d0", 25, 'L', 18, 6, 16, 75, 0, 0),
  Object(IS_ASLEEP | WAKENS | WANDERS, "4d4/3d7", 92, 'M', 250, 18, 126, 85, 0, 25),
  Object(IS_ASLEEP, "0d0", 25, 'N', 37, 10, 19, 75, 0, 100),
  Object(IS_ASLEEP | WANDERS | WAKENS, "1d6", 25, 'O', 5, 4, 13, 70, 0, 10),
  Object(IS_ASLEEP | IS_INVIS | WANDERS | FLITS, "5d4", 76, 'P', 120, 15, 23, 80, 0, 50),
  Object(IS_ASLEEP | WAKENS | WANDERS, "3d5", 30, 'Q', 20, 8, 17, 78, 0, 20),
  Object(IS_ASLEEP | WAKENS | WANDERS, "2d5", 19, 'R', 10, 3, 12, 70, 0, 0),
  Object(IS_ASLEEP | WAKENS | WANDERS, "1d3", 8, 'S', 2, 1, 9, 50, 0, 0),
  Object(IS_ASLEEP | WAKENS | WANDERS, "4d6", 64, 'T', 125, 13, 22, 75, 0, 33),
  Object(IS_ASLEEP | WAKENS | WANDERS, "4d9", 88, 'U', 200, 17, 26, 85, 0, 33),
  Object(IS_ASLEEP | WAKENS | WANDERS, "1d14", 40, 'V', 350, 19, 126, 85, 0, 18),
  Object(IS_ASLEEP | WANDERS, "2d7", 42, 'W', 55, 14, 23, 75, 0, 0),
  Object(IS_ASLEEP, "4d6", 42, 'X', 110, XEROC1, XEROC2, 75, 0, 0),
  Object(IS_ASLEEP | WANDERS, "3d6", 33, 'Y', 50, 11, 20, 80, 0, 20),
  Object(IS_ASLEEP | WAKENS | WANDERS, "1d7", 20, 'Z', 8, 5, 14, 69, 0, 0),
];

// object.c
final List<Identity> idPotions = [
  Identity(100, "blue ", "of increase strength ", 0),
  Identity(250, "red ", "of restore strength ", 0),
  Identity(100, "green ", "of healing ", 0),
  Identity(200, "grey ", "of extra healing ", 0),
  Identity(10, "brown ", "of poison ", 0),
  Identity(300, "clear ", "of raise level ", 0),
  Identity(10, "pink ", "of blindness ", 0),
  Identity(25, "white ", "of hallucination ", 0),
  Identity(100, "purple ", "of detect monster ", 0),
  Identity(100, "black ", "of detect things ", 0),
  Identity(10, "yellow ", "of confusion ", 0),
];

final List<Identity> idScrolls = [
  Identity(505, "", "of protect armor ", 0),
  Identity(200, "", "of hold monster ", 0),
  Identity(235, "", "of enchant weapon ", 0),
  Identity(235, "", "of enchant armor ", 0),
  Identity(175, "", "of identify ", 0),
  Identity(190, "", "of teleportation ", 0),
  Identity(25, "", "of sleep ", 0),
  Identity(610, "", "of scare monster ", 0),
  Identity(210, "", "of remove curse ", 0),
  Identity(100, "", "of create monster ", 0),
  Identity(25, "", "of aggravate monster ", 0),
];

final List<Identity> idWeapons = [
  Identity(150, "short bow ", "", 0),
  Identity(15, "arrows ", "", 0),
  Identity(35, "shurikens ", "", 0),
  Identity(370, "mace ", "", 0),
  Identity(480, "long sword ", "", 0),
  Identity(590, "two-handed sword ", "", 0),
];

final List<Identity> idArmors = [
  Identity(300, "leather armor ", "", UNIDENTIFIED),
  Identity(300, "ring mail ", "", UNIDENTIFIED),
  Identity(400, "scale mail ", "", UNIDENTIFIED),
  Identity(500, "chain mail ", "", UNIDENTIFIED),
  Identity(600, "banded mail ", "", UNIDENTIFIED),
  Identity(600, "splint mail ", "", UNIDENTIFIED),
  Identity(700, "plate mail ", "", UNIDENTIFIED),
];

final List<Identity> idWands = [
  Identity(25, "", "of teleport away ", 0),
  Identity(50, "", "of slow monster ", 0),
  Identity(45, "", "of kill monster ", 0),
  Identity(8, "", "of invisibility ", 0),
  Identity(55, "", "of polymorph ", 0),
  Identity(2, "", "of haste monster ", 0),
  Identity(25, "", "of put to sleep ", 0),
  Identity(0, "", "of do nothing ", 0),
];

// object.c
List<List<int>> screen = List.generate(SROWS, (_) => List<int>.filled(SCOLS, 0));

Fighter rogue = Fighter();

// room.c
List<Room> rooms = List.generate(MAXROOMS, (_) => Room());

// all global variables are collected in `g` so that I don't have to use "global"
class G {
  // hit.py
  Object? fightMonster;
  bool detectMonster = false;
  String hitMessage = "";

  // init.py
  String playerName = "";
  bool cantInt = false;
  bool didInt = false;
  Exception? exc;

  // level.py
  int currentLevel = 0;
  int maxLevel = 1;
  String hungerStr = "";
  int partyRoom = 0;

  // message.py
  bool messageCleared = true;
  String messageLine = "";
  int messageCol = 0;

  // monster.py
  ObjHolder levelMonsters = ObjHolder();

  // object.py
  ObjHolder levelObjects = ObjHolder();
  bool hasAmulet = false;
  int foods = 0;

  // pack.py
  List<bool> ichars = List.filled(26, false);

  // play.py
  bool interrupted = false;

  // room.py
  int currentRoom = 0;

  // special_hit.py
  bool beingHeld = false;

  // use.py
  int halluc = 0;
  int blind = 0;
  int confused = 0;
  //int detectMonster = 0;
}

final g = G();

// random.c
Random _random = Random();

void srandom(int x) {
  _random = Random(x);
}

int getRand(int x, int y) {
  return _random.nextInt(y - x + 1) + x;
}

bool randPercent(int percentage) {
  return getRand(1, 100) <= percentage;
}

typedef Monster = Object;
