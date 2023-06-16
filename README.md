Pyrogue in Dart
===============

This is an automatic ChatGPT translation of [Pyrogue](https://github.com/sma/pyrogue) from Python to Dart. The very first commit is the raw translation. Further commits are my attempts to make it actually work.

Initially, there are 2K+ errors mostly because there are no imports.

I export every other package from `globals.dart` and import that file in every other package to make all global variables and function known. This reduces the number of errors to 820.