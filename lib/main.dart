import 'globals.dart';

void main() {
  init();
  while (true) {
    clearLevel();
    makeLevel();
    putObjects();
    putStairs();
    putMonsters();
    putPlayer();
    lightUpRoom();
    printStats();
    playLevel();
    g.levelObjects.nextObject = null;
    g.levelMonsters.nextObject = null;
    clear();
  }
}

// TODO(sma): see other code using g.exc
// try {
//   main();
// } catch (e) {
//   // we have to delay the exception until init.cleanUp to see it
//   g.exc = sys.exc_info();
// }