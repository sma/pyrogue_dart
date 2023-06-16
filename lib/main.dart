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

// hackish attempt to fix up the imports
for (final m in sys.modules.values) {
  if (hasattr(m, 'MONSTERS')) {
    m.__dict__.update(sys.modules['globals'].__dict__);
  }
}

try {
  main();
} catch (e) {
  // we have to delay the exception until init.cleanUp to see it
  g.exc = sys.exc_info();
}