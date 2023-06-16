import 'dart:io';

import 'globals.dart';

void init() {
  g.playerName = Platform.environment['USER'] ?? Platform.environment['USERNAME'];
  if (g.playerName == null) {
    stderr.write("Hey! Who are you?");
    exit(1);
  }
  print("Hello ${g.playerName}, just a moment while I dig the dungeon...");

  // register byebye() function to be called on exit
  exitHandler.register(byebye);

  initscr();
  for (var i = 0; i < 26; i++) {
    g.ichars[i] = 0;
  }
  startWindow();
  //signal(SIGTSTP, tstp);
  //signal(SIGINT, onintr);
  //signal(SIGQUIT, byebye);
  //if (LINES < 24 || COLS < 80) {
  //    cleanUp("must be played on 24 x 80 screen");
  //}
  //LINES = SROWS;

  srandom(ProcessInfo().pid);
  initItems();

  g.levelObjects.nextObject = null;
  g.levelMonsters.nextObject = null;
  playerInit();
}

void playerInit() {
  rogue.pack.nextObject = null;
  var obj = getAnObject();
  getFood(obj);
  addToPack(obj, rogue.pack, 1);

  // initial armor
  obj = getAnObject();
  obj.whatIs = ARMOR;
  obj.whichKind = RING;
  obj.clasz = RING + 2;
  obj.isCursed = 0;
  obj.isProtected = 0;
  obj.damageEnchantment = 1;
  obj.identified = 1;
  addToPack(obj, rogue.pack, 1);
  rogue.armor = obj;

  // initial weapons
  obj = getAnObject();
  obj.whatIs = WEAPON;
  obj.whichKind = MACE;
  obj.isCursed = 0;
  obj.damage = "2d3";
  obj.toHitEnchantment = 1;
  obj.damageEnchantment = 1;
  obj.identified = 1;
  addToPack(obj, rogue.pack, 1);
  rogue.weapon = obj;

  obj = getAnObject();
  obj.whatIs = WEAPON;
  obj.whichKind = BOW;
  obj.isCursed = 0;
  obj.damage = "1d2";
  obj.toHitEnchantment = 1;
  obj.damageEnchantment = 0;
  obj.identified = 1;
  addToPack(obj, rogue.pack, 1);

  obj = getAnObject();
  obj.whatIs = WEAPON;
  obj.whichKind = ARROW;
  obj.quantity = getRand(25, 35);
  obj.isCursed = 0;
  obj.damage = "1d2";
  obj.toHitEnchantment = 0;
  obj.damageEnchantment = 0;
  obj.identified = 1;
  addToPack(obj, rogue.pack, 1);
}

void cleanUp(String estr) {
  move(LINES - 1, 0);
  refresh();
  stopWindow();
  print(estr);
  if (g.exc != null && g.exc?.first is! SystemExit) {
    stderr.write("---------");
    //traceback.print_exception(*g.exc)
    traceback.print_exception(g.exc!);
    stderr.write("---------");
  }
  exit(0);
}

void startWindow() {
  crmode();
  noecho();
  nonl();
  edchars(0);
}

void stopWindow() {
  endwin();
  edchars(1);
}

void

 byebye() {
  cleanUp("Okay, bye bye!");
}

void onintr() {
  if (g.cantInt != 0) {
    g.didInt = 1;
  } else {
    //signal(SIGINT, SIG_IGN);
    checkMessage();
    message("interrupt", 1);
    //signal(SIGINT, onintr);
  }
}

void edchars(int mode) {
  // TODO: Implement the edchars function based on its usage in the code.
}