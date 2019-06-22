
include <thirdparty/strings.scad>;

X = [1, 0, 0];
Y = [0, 1, 0];
Z = [0, 0, 1];
Xi = 0;
Yi = 1;
Zi = 2;

function axisLabel(axis) = axis.x ? "X" : axis.y ? "Y" : "Z";

_e = 0.01;

module t(v) {
    translate(v) children();
}

module tX(x) {
    translate([x,0,0]) children();
}

module tY(y) {
    translate([0,y,0]) children();
}

module tZ(z) {
    translate([0,0,z]) children();
}

module r(v) {
    rotate(v) children();
}

module s(v) {
    scale(v) children();
}

// Do translation if flag is true, identity transform otherwise
module translate_if(flag, t) {
    translate([flag ? t[0] : 0, flag ? t[1] : 0, flag ? t[2] : 0]) children();
}
module t_if(flag, t) {
    translate_if(flag, t) children();
}

// Do rotation if flag is true, identity transform otherwise
module rotate_if(flag, r) {
    rotate([flag ? r[0] : 0, flag ? r[1] : 0, flag ? r[2] : 0]) children();
}
module r_if(flag, r) {
    rotate_if(flag, r) children();
}

// Do scale if flag is true, identity transform otherwise
module scale_if(flag, s) {
    rotate([flag ? s[0] : 1, flag ? s[1] : 1, flag ? s[2] : 1]) children();
}
module s_if(flag, s) {
    scale_if(flag, s) children();
}

// Alias for mirror on X axis
module flipX() {
    mirror(X) children();
}

module symmetricX() {
    children();
    mirror(X) children();
}

module flipX_if(flag) {
    if (flag) flipX() children();
    else children();
}

// Alias for mirror on Y axis
module flipY() {
    mirror(Y) children();
}

module symmetricY() {
    children();
    mirror(Y) children();
}

// Alias for mirror on Z axis
module flipY_if(flag) {
    if (flag) flipY() children();
    else children();
}

// Alias for mirror on Z axis
module flipZ() {
    mirror(Z) children();
}

module symmetricZ() {
    children();
    mirror(Z) children();
}

module symmetricXY() {
    symmetricX() symmetricY() children();
}

module symmetricXYZ() {
    symmetricX() symmetricY() symmetricZ() children();
}

// Alias for mirror on Z axis
module flipZ_if(flag) {
    if (flag) flipZ() children();
    else children();
}

module show_if(flag) {
    if (flag) children();
}

module hull_if(flag) {
    if (flag) hull() children();
    else children();
}

module union_if(flag) {
    if (flag) union() children();
    else children(0);
}

module intersection_if(flag) {
    if (flag) intersection() {
        children(0);
        children([1:$children-1]);
    }
    else children(0);
}

module difference_if(flag) {
    if (flag) difference() {
        children(0);
        children([1:$children-1]);
    }
    else children(0);
}

function axisMin(axis, list) = min([for (vect = list) vect[axis]]);
function axisMax(axis, list) = max([for (vect = list) vect[axis]]);
function axisRange(axis, list) = axisMax(axis, list) - axisMin(axis, list);
function axisSum(axis, list, i = 0) = i == len(list) ? 0 : list[i][axis] + axisSum(axis, list, i+1);

// Slightly expand object in one axis (by translating on that axis slightly +/-)
module epsilon(axis, e = 0.1) {
    _axis = lower(axis);
    
    translate([
        (_axis == "x+" || _axis == "x" || axis.x) ? e : 0, 
        (_axis == "y+" || _axis == "y" || axis.y) ? e : 0, 
        (_axis == "z+" || _axis == "z" || axis.z) ? e : 0
        ]) children();

    children();

    translate([
        (_axis == "x-" || _axis == "x" || axis.x) ? -e : 0,
        (_axis == "y-" || _axis == "y" || axis.y) ? -e : 0, 
        (_axis == "z-" || _axis == "z" || axis.z) ? -e : 0
        ]) children();
}

module e(axis, e = 0.1) {
    epsilon(axis, e) children();
}

// Nicked from BOLTS
function type(P) =
	(len(P) == undef)
	?	(P == true || P == false)
		? "boolean"
		: (P == undef)
			? "undef"
			: "number"
	:	(P + [1] == undef)
		?	"string"
		:	"vector";

// Type tests - given docs on openscad, this may break in newer versions (they have is_bool instead)
assert(type(true) == "boolean", "'type' function doesn't work on boolean true");
assert(type(false) == "boolean", "'type' function doesn't work on boolean false");
assert(type(0) == "number", "'type' function doesn't work on number 0");
assert(type(undef) == "undef", "'type' function doesn't work on undef");

function permutation(opts, i = 0) = (
    i == len(opts) - 2 ? 
        [for (u = opts[i], v = opts[i+1]) concat(type(u) == "vector" ? u : [u], type(v) == "vector" ? v : [v])] :
        [for (u = opts[i], v = permutation(opts, i+1)) concat(type(u) == "vector" ? u : [u], v)]
);

// Find the first member of a vector that matches a test - used for i.e. selecting one from a bunch of optional arguments (see shapes.scad)
function firstNotFalse(v) = [for (i = v) if (i != false) i][0];
function firstNumber(v) = [for (i = v) if (type(i) == "number") i][0];

// firstXXX tests
assert(firstNotFalse([false, 0]) == 0, "'firstNotFalse' basic functional test failed");
assert(firstNumber([false, undef, 0]) == 0, "'firstNumber' basic functional test failed");

// Zip two vectors together
function zip(a, b) = [for (i = [0:len(a)-1]) [a[i], b[i]] ];

// Repeat something X times in a vector
function repeat(a, times) = [for (i = [0:times-1]) a];

// Multiply two vectors piecewise (* operator in scad on vectors is cross-product)
function mult(v1, v2) = [v1.x * v2.x, v1.y * v2.y, v1.z * v2.z];

// Flip a vector around a (or several) axis
function flip(v, a) = [v.x * (a.x ? -1 : 1), v.y * (a.y ? -1 : 1), v.z * (a.z ? -1 : 1)];

// Rotate a 2D point p clockwise by a in degrees
function rotate2D(p, a) = [
    p.x * cos(a) - p.y * sin(a),
    p.x * sin(a) + p.y * cos(a)
];

include <ease.scad>;
include <tween.scad>;

