# Hamish's common SCAD stuff

A bunch of utilities / common shapes / common third party libs.

These files are moderately stable:

- utils.scad - Basic shorthand and utility methods
- tween.scad - Describe a shape that tweens between two states in a slightly nicer way
- ease.scad - Ease functions for tween
- cs.scad - Like attach, lets you describe difference co-ordinate systems to describe attachment points on components
- thirdparty/* - Other people's code I find I commonly use. Generally not depended on by things in this library.

These are almost certainly not:

- shapes.scad - Various more complex shapes, often making things easier to print
- vitamins/* - Various vitamins I use that I didn't find nice thirdparty libs for

Everything under LGPL V3, except the stuff in "thirdparty", which is under
whatever license the original author made it available under.

Note this uses submodules, so either do `git submodule init && git submodule update` after cloning
or `git clone --recurse-submodules` when you clone it
