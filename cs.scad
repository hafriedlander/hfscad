/*
Vector reminder

Row vectors are [x, y, z]
Column vectors are [ [x], [y], [z] ]

For row vectors, combine affine transforms thusly: first A and then B is A*B. Use at v*AT
For column vectors, combine affine transforms thusly: first A and then B is B*A. Use as AT*v

The exact format of the affine transform is also different between the two (mostly(?) where the
translate component goes)

The below is all for column vectors - this is primarily because multmatrix also expects column vectors

If you see conflicting structures or ordering on the internet, it may be because they're using
row vectors
*/

// For argument type detection
function _align_argType(t) =
    len(t) == undef ? "int" :
    len(t[0]) == undef ? "vector" :
    "matrix";

// Matrix_invert taken from scad-utils (can't just include because spline.scad has active modules)
use <thirdparty/scad-utils/lists.scad>;
function det(m) = let(r=[for(i=[0:1:len(m)-1]) i]) det_help(m, 0, r);
function det_help(m, i, r) = len(r) == 0 ? 1 : 
    m[len(m)-len(r)][r[i]]*det_help(m,0,remove(r,i)) - (i+1<len(r)? det_help(m, i+1, r) : 0);
function matrix_invert(m) = let(r=[for(i=[0:len(m)-1]) i]) [for(i=r) [for(j=r)
    ((i+j)%2==0 ? 1:-1) * matrix_minor(m,0,remove(r,j),remove(r,i))]] / det(m);
function matrix_minor(m,k,ri, rj) = let(len_r=len(ri)) len_r == 0 ? 1 :
    m[ri[0]][rj[k]]*matrix_minor(m,0,remove(ri,0),remove(rj,k)) - (k+1<len_r?matrix_minor(m,k+1,ri,rj) : 0);

X = [1, 0, 0];
Y = [0, 1, 0];
Z = [0, 0, 1];

// Affine transform that does nothing
identityAT = 
    [
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ];

// Return an affine transform that does A and then B
function combineAT(a, b) = b * a;

// Return an affine transform that translates to a point
function translateAT(vector) =
    [
        [1, 0, 0, vector.x],
        [0, 1, 0, vector.y],
        [0, 0, 1, vector.z],
        [0, 0, 0, 1],
    ];

// Return an affine transform matrix that rotates / mirrors / skews to match three vectors
// that define the X, Y and Z axes
function alignToAxiiAT(axii) = 
    let(pr = [X, Y, Z])
    let(dr = axii)

    [
        [pr[0] * dr[0], pr[0] * dr[1], pr[0] * dr[2], 0],
        [pr[1] * dr[0], pr[1] * dr[1], pr[1] * dr[2], 0],
        [pr[2] * dr[0], pr[2] * dr[1], pr[2] * dr[2], 0],
        [0, 0, 0, 1]
    ];

// Change an affine transform to have no translate component
// Could be written more elegantly, but this is (probably?) faster
function stripTranslateFromAT(at) =
    [
        [at[0][0], at[0][1], at[0][2], 0],
        [at[1][0], at[1][1], at[1][2], 0],
        [at[2][0], at[2][1], at[2][2], 0],
        [0, 0, 0, 1]
    ];


// Affine transforms expects points to be in a 4x1 column format, not a 1x4 row format
function pointAsColumn(point) = [ 
    [point.x], 
    [point.y], 
    [point.z], 
    [1] 
];

// Apply an affine transform to a point (passed in SCAD-standard 3-number row format)
function applyATToPoint(at, point) =
    let (res = at * pointAsColumn(point))
    [res[0][0], res[1][0], res[2][0]];

// Apply an affine transform to a vector (passed in SCAD-standard 3-number row format)
// Same as applyATToPoint, but doesn't translate
function applyATToVector(at, vector) =
    applyATToPoint(stripTranslateFromAT(at), vector);

// Return a new co-ordinate system
function newCS(origin = [0, 0, 0], axii = [X, Y, Z]) = 
    let(_origin = _align_argType(origin) == "vector" ? origin : [0, 0, 0])
    let(_axii = _align_argType(origin) == "matrix" ? origin : axii)

    combineAT(alignToAxiiAT(_axii), translateAT(_origin));

// Define the "default" co-ordinate system - i.e. originCS = newCS();
// (but since this is just identity, we don't bother actually calculating
globalCS = identityAT;

// Render the children as if they were in innerCS co-ordinate system (instead of their internal default CS)
// Optionally provide a non-default co-ordinate system to transform to
module inCS(innerCS = globalCS, outerCS = globalCS, label = false){
    at = combineAT(matrix_invert(innerCS), outerCS);
    multmatrix(at) children();
    if (label) multmatrix(at) drawCS(globalCS, label);
}

// Transform a point, as if it were in innerCS co-ordinate system, to the outerCS co-ordinate system
// If arguments aren't named:
//    Two argument version: innerCS, point (transformed to global CS)
//    Three argument version: innerCS, outerCS, point
function inCS(innerCS, outerCS = globalCS, point) =
    let(_outerCS = point == undef ? globalCS : outerCS)
    let(_point = point == undef ? outerCS : point)

    applyATToPoint(combineAT(matrix_invert(innerCS), _outerCS), _point);

// Same things as inCS, but for a vector (translation component is ignored)
function vectorInCS(innerCS, outerCS = globalCS, point) =
    let(_outerCS = point == undef ? globalCS : outerCS)
    let(_point = point == undef ? outerCS : point)

    applyATToVector(combineAT(matrix_invert(innerCS), _outerCS), _point);

// Create a new co-ordinate system that combines innerCS with outerCS
// In other words, these two are equivalent:
//        inCS(outerCS, inCS(innerCS, point))
//        inCS(csInCS(innerCS, outerCS), point)
function csInCS(innerCS, outerCS) =
    combineAT(outerCS, innerCS);

// Draw a co-ordinate system for debugging
module drawCS(cs, label=false) {
    inCS(globalCS, cs) {
        for (axis = [X, Y, Z]) {
            color(axis) {
                cube([0.5, 0.5, 0.5] + 200 * axis);
                inCS(outerCS=newCS([0,0,0], [axis.x ? Y : X, axis, axis.z ? Y : Z])) {
                    t([2, 32]) text(axisLabel(axis));
                    for (o=[10:10:100]) {
                        t(o*Y) cube([5, 0.5, 0.5], center=true);
                    }
                    t(100*Y) cube([15, 0.5, 0.5], center=true);
                }
            }
        }
        if (label) r([0, 0, 45]) t([6, 0, 0]) text(label, valign="center");
    }
}

flipXCS = newCS(axii=[-X,  Y,  Z]);
flipYCS = newCS(axii=[ X, -Y,  Z]);
flipZCS = newCS(axii=[ X,  Y, -Z]);
