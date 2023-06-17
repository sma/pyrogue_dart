import 'globals.dart';

void main() {
  init();
  try {
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
      g.levelObjects.clear();
      g.levelMonsters.clear();
      clear();
    }
  } catch (error, st) {
    g.exc = '$error\n$st';
  } finally {
    byebye();
  }
}
