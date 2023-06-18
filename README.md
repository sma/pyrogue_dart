Pyrogue in Dart
===============

This is based on an automated ChatGPT translation of [Pyrogue](https://github.com/sma/pyrogue) from Python to Dart. The very first commit is the raw translation. Further commits are my attempts to make it actually work.

Initially, there are 2K+ errors mostly because there are no imports. It took me about an hour to create this version.

I fixed all imports and all functions and variables that were named differently in different files. I also fixed some mistranslations due to tuples. ChatGPT was also not translating octal constants correctly. I spent about three hours on this.

Then, I added a simple `curses` implementation in about 20 minutes.

Last but not least, I hunted down some bugs and even found one in the 15 year old Python version. In total, I probably spent the better part of a day on this.

The game is playable but not yet bug-free.

To play, enter `dart run` on your favorite VT100 compatible terminal.

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

_What follows, is the original README …_

Pyrogue
=======

For fun, I ported a 20 years old clone of a nearly 30 years old computer game
called [Rogue][rogue] to Python. The C code was written by Tim Stoehr in 1986.
The Python code was written in early 2008 by me, Stefan Matthias Aust. It is
very unpythonic because it's a raw and direct port of the C code to Python
2.5.x, nothing to be particularly proud of.

It requires curses, so it probably runs only on Unix-like systems.

[rogue]:http://en.wikipedia.org/wiki/Rogue_(computer_game)

Screenshoots
------------

Our fearless hero (`@`) is about to climb down to level 3 of the Dungeons of
Doom, equipped with some food, a magical armor, a long sword and some unknown
magical potions. The `%` denotes the stairway.

<pre class="console">
                                                a) a ration of food
                              -------------     b) +1 ring mail [4] being worn
  -------------               |           |     c) a +1,+1 mace
  |           |###############+           |     d) a +1,+0 short bow
  |           +#              |           |     e) 33 +0,+0 arrows
  --------+----               -----+-------     g) a black potion
          #                        #            h) a yellow potion
          #                        ###          j) a long sword in hand
          ####                       #          --press space to continue--
       ------+-----------           -+--------------              --------------
       |                |       ####+..............|              |            |
       |                +########   |..%.....@.....+#########     |            |
       |                |           |..............|        ######+            |
       ------------------           ---------+------              --------------
                                             #
                              ################
                            --+------                          --------
                            |       |                          |      |
                            |       +#####                     |      |
                            ---------    #                     |      |
                                         #                     |      |
                                         ######################+      |
                                                               --------
Level: 2  Gold:  59  Hp: 35(35)  Str: 15(16)  Arm:  4  Exp: 4/40 
</pre>

Running the Game
----------------

	python main.py

I ported 98% of the code. The save function is missing. The code has bugs, though. 

It took me about 15 hours to rewrite 6282 lines of C code into 4065 lines of Python code and find the oversights I made.

Documentation
-------------
	Movement:

	 y  k  u   by default, @ moves one space and picks up items or attacks
	  \ | /    with SHIFT, @ moves as many spaces as possible
	h --+-- l  with CTRL, @ moves until something interesting is nearby
	  / | \    use m <dir> to move without picking up   
	 b  j  n   use f/F <dir> to attack without moving

	Other commands:

	.       - wait (precede with numbers to wait longer)
	*       - when asked for an item, show inventory
	>       - go one level down
	<       - go one level up (only possible with amulet)
	a
	b       - move downleft (see above)
	c <itm> - call (name) an item (NOT IMPLEMENTED)
	d <itm> - drop item
	e <itm> - eat something
	f <dir> - fight
	F <dir> - fight to death
	g
	h       - move left (see above)
	i       - show inventory
	I <itm> - show only a single item (for whatever reason...)
	j       - move up (see above) 
	k       - move down (see above)
	l       - move right (see above)
	m <dir> - move onto a field without picking up an item
	n       - move downright (see above)
	o
	p
	P       - put on (wear) armor
	q <itm> - quaff (drink) a potion
	Q       - quit the game
	r <itm> - read a scroll
	s
	t <d><i>- throw a weapon (for arrows, you need to wield a bow)
	T       - take off armor
	u       - move upright (see above)
	v       - print version number
	w <itm> - wield (use) a weapon
	W <itm> - wear armor
	x
	y       - move upleft (see above)
	z <d><i>- zap a wand (against a monster nearby)
