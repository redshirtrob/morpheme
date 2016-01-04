# Morpheme

*Note* I'm publishing this code in case someone finds it interesting.
 It's a POC on a game concept I was developing, but I ended up taking
 full-tme employment instead.  Many caveats are called out below.

## Overview

Morpheme is a word search game with a twist.  To "find" the words in
the grid, the user must shift the rows or columns to create words.
Shift rows left or right by dragging left or right on the target row.
Similarly, shift rows up or down by dragging up or down on the target
column.

When you've created a word on the grid, tap the word on the word list
and it will lock into place.  Once words are locked into place those
letters can no longer be moved.  Locked words can be unlocked by
tapping the word in the word list.

You win the game when all words are locked into place.

There are likely many correct solutions.  Words are only formed left
to right and top to bottom.  Unlike traditional word searches there
are no backwards or diagonal words...yet.

## Building

This project should build with recent versions of Xcode.  There are a
number of warnings related to deprecated methods, but they can be
ignored for now.  This code was originally developed for iOS 5 on
Xcode 4 and has not been updated since then.

## Running

This project should be run on a non-retina iPad.  There are no retina
assets so the game will look very "weird" on retina devices.
