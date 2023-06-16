Pyrogue in Dart
===============

This is an automatic ChatGPT translation of [Pyrogue](https://github.com/sma/pyrogue) from Python to Dart. The very first commit is the raw translation. Further commits are my attempts to make it actually work.

Initially, there are 2K+ errors mostly because there are no imports.

I export every other package from `globals.dart` and import that file in every other package to make all global variables and function known. This reduces the number of errors to 820.

In Python `g` is a class with static variables. But here, `G` is a class and I need to create a global variable `g`. Unfortunately, all `g.` names still use snake case. There are 34 occurences, I will fix by hand. (662 errors)

The type `char` needs to become a `String` (653 errors)

There is no `Monster` type, so I create a typealias for `Object`.

The `Object` didn't correctly initialize variables. `globals.dart` is done. (539 errors)
