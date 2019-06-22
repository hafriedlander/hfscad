
include <utils.scad>;

// Cylinder for holes (touches radius from outside rather than inside)
module cylinder_outer(h, r1=false, r2=false, center=false, fn=false, r=false, d=false, d1=false, d2=false){
    _r1 = firstNumber([r1, r, d1/2, d/2]);
    _r2 = firstNumber([r2, r, d2/2, d/2]);
    _fn = firstNumber([fn, $fn]);

    fudge = 1/cos(180/_fn);
    cylinder(h=h, r1=_r1*fudge, r2=_r2*fudge, $fn=_fn, center=center);
}

module cylinder_io(h, r1=false, r2=false, center=false, fn=false, r=false, d=false, d1=false, d2=false, outer=false) {
    _r1 = firstNumber([r1, r, d1/2, d/2]);
    _r2 = firstNumber([r2, r, d2/2, d/2]);
    _fn = firstNumber([fn, $fn]);

    if (outer) cylinder_outer(h=h, r1=_r1, r2=_r2, $fn=_fn, center=center);
    else cylinder(h=h, r1=_r1, r2=_r2, $fn=_fn, center=center);
}

module cylinder_tapered(h, r=false, center=false, d=false, outer=false) {
    _r= firstNumber([r, d/2]);
    _h = h - _r * 2;

    t_if(!center, h/2*Z) {
        cylinder_io(r=_r, h=_h, center=true, outer=outer);
        symmetricZ() tZ(_h/2) cylinder_io(r1=_r, r2=0, h=_r, center=false, outer=outer);
    }
}

nozzle_dia=0.4;
layer_height=0.162;

// From https://gilesbathgate.com/2016/02/07/polyholes-revisited/
// Does Arc Compensation for holes, but this is nessecarily nozzile diameter & layer height sensitive
// Note: may be not actually correct (see next blog post in series)
module cylinder_outer2(h, r1=false, r2=false, center=false, fn=false, r=false, d=false, d1=false, d2=false){
    _r1 = firstNumber([r1, r, d1/2, d/2]);
    _r2 = firstNumber([r2, r, d2/2, d/2]);    
    _fn = firstNumber([fn, $fn]);

    pi=3.141592;
    function width(d,h) = h-(pi*((h*h)-(d*d)))/(4*h);
    function arc(r,t) = 0.5*(t+sqrt((t*t)+4*(r*r)));
    function polyhole(r,n,t) = arc(r,t)/cos(180/n);

    t=width(nozzle_dia,layer_height);
    pr1=polyhole(_r1, _fn, t);
    pr2=polyhole(_r2, _fn, t);
  
    cylinder(h=h, r1=pr1, r2=pr2, $fn=_fn, center=center);    
}

// Cube with all edges rounded. Same arguments as built-in cube, plus r or d for size of round
module roundedCube(size, r=false, d=false, center=false) {
    _size = type(size) == "number" ? [size, size, size] : size;
    _r = firstNumber([r, d/2]);

    x=_size.x - _r*2;
    y=_size.y - _r*2;
    z=_size.z - _r*2;

    t_if(!center, [x/2, y/2, z/2]) minkowski() {
        cube([x, y, z], center=true);
        sphere(r=_r);
    }
}

module cube2(size, center=[0, 0, 0]) {
    t([-center.x * size.x/2, -center.y * size.y/2, -center.z * size.z/2]) cube(size=size, center=true);
}

// Square-base truncated pyramid
module truncatedPyramid(x, y1, y2, z, center=false) {
    t_if(!center, [x/2, y1/2]) {
        linear_extrude(z, scale=y2/y1) square([x, y1], center=true);
    }
}

module tube(h, d, id=false, center=true) {
    if (id) {
        difference() {
            tube(h=h, d=d, center=center);
            epsilon("z") tube(h=h, d=id, center=center);
        }
    }
    else {
        cylinder(h=h, r1=d/2, r2=d/2, center=center);
    }
}

module printableTube(h, d, maxOverhang=50, center=true) {
    r = d/2;
    yi = r * sin(maxOverhang);
    xi = sqrt(r*r-yi*yi);
    yd = r-yi;
    xd = tan(maxOverhang) * yd;

    t_if(center, -h/2*Z) {
        cylinder(h=h, r1=r, r2=r);
        linear_extrude(h) polygon([[-xi, yi], [-xi+xd, r], [xi-xd, r], [xi, yi]]);
    }
}

module hump(dx1, dy1, d2, l, z) {
    t(d2/2*Y) {
        // Up-humps
        difference() {
            union() {
                t(l/2 * -X) scale([1, dy1/dx1, 1]) tube(z, dx1);
                t(l/2 * X) scale([1, dy1/dx1, 1]) tube(z, dx1);
            }
            t(dy1/4 * 1.01 * -Y) cube([dx1 + l, dy1/2, z*1.01], center=true);
        }
        // Joint between hump curves
        t(dy1/4 * Y) cube([l, dy1/2, z], center=true);
        t(d2/4 * -Y) cube([(dx1 + l), d2/2, z], center=true);

        // Bottom curves
        for (_X = [-X, X]) {
            difference() {
                t((d2/4 + l/2 + dx1/2 - 0.01)*_X) t((-d2/4) * Y) cube([d2/2, d2/2, z], center=true);
                t((d2/2 + l/2 + dx1/2 - 0.01)*_X) t((0) * Y) tube(z*1.02, d2);
            }
        }
    }
}

module spiral(r1 = 4, r2 = 8, h=5, ta=120) {
    points = [for (a = [-90:1:ta+10])
        let (t = min(a/ta, 1))
        let (c = cos(a))
        let (s = sin(a))
        let (x = r1 + (r2 - r1) * t)
        [x * c, -x * s]
    ];

    linear_extrude(h) polygon(concat([[0, 0]], points));
}


/*
 * A tube which increases in size and rotates around a point.
 * Center of each slice is offset from origin the same distance
 * a = angle to rotate around
 * r = radius from center to middle of each slice
 * d1 = diameter of first slice
 * d2 = diameter of last slice
 */
module radial_horn(a, r, d1, d2, fn=false) {
    _fn = firstNumber([fn, $fn]);

    ddiff = d2-d1;
    step = 1/fn;
    for (i = [0 : step : 1-step+0.00001]) hull() {
        r(i*a*Y) t(r*X) cylinder(d=d1 + ddiff*i, h=_e, center=true);
        r((i+step)*a*Y) t(r*X) cylinder(d=d1 + ddiff*(i+step), h=_e, center=true);
    }
}

// Rectange with rounded corners. Both s & (r or d) can be singles or vectors
module roundedSquare(size, r=false, d=false, center=true) {
    _s = type(size) == "vector" ? size : [size, size];
    _r = r == false ?
        (type(d) == "vector" ? d : [d, d]) * 0.5:
        (type(r) == "vector" ? r : [r, r]);
    _d = 2 * _r;

    // Limit radius to be no more than size, per axis
    _dl = [min(_d[0], _s[0]), min(_d[1], _s[1])];
    _rl = _dl / 2;

    core = _s - _dl;

    t_if(!center, 0.5*_s) {
        square(size=core, center=true);
        symmetricY() t((core.y*0.5 + _rl.y*0.5)*Y) square(size=[core.x, _rl.y], center=true);
        symmetricX() t((core.x*0.5 + _rl.x*0.5)*X) square([_rl.x, core.y], center=true);
        symmetricX() symmetricY() t(0.5*core) scale([_rl.x/_rl.y, 1]) circle(_rl.y, center=true);
    }
}

module torus(ir=false, or=false, id=false, od=false) {
    _ir = firstNumber([ir, id/2]);
    _or = firstNumber([or, od/2]);
    rotate_extrude(convexity = 10) translate([_or, 0, 0]) circle(r=_ir);
}

// Nutcatch sidecut from nutsnbolts _but_ it's beveled at 45 on the top so it can be cut
// without support
// NOTE: Unlike nutsbolts, bottom of catch is at Z=0, and it goes up from there

module nutcatch_sidecut_beveled(name="M3", l=50) {
    include <thirdparty/nutsnbolts/cyl_head_bolt.scad>;
    include <thirdparty/nutsnbolts/data-access.scad>;
    include <thirdparty/nutsnbolts/data-metric_cyl_head_bolts.scad>;

    df = _get_fam(name);
    w = df[_NB_F_NUT_KEY];
    h = df[_NB_F_NUT_HEIGHT];

    tZ(h) {
        nutcatch_sidecut(name, l);

        blend(10) between([
            tween("s", 1, 0),
            tween("z", 0, w/2),
        ]) tZ(tval("z")) s([tval("s"), tval("s"), _e]) nutcatch_sidecut(name, l);
    }
}

// A cube, but with Z varying over X
module ramp(size, smallZ, center=false) {
    t_if(center, size*-0.5) tY(size.y) r(90*X) linear_extrude(size.y) polygon([
        [0, 0],
        [0, size.z],
        [size.x, smallZ],
        [size.x, 0]
    ]);
}

// Not sure if this is useful - supposed to be able to intersect / difference one side of a plane. But not really possible,
// so this is just a massive cube. Does this cause accuracy and/or perf. issues? No idea.
module plane(axis) {
    t([500 * axis.x, 500 * axis.y, 500 * axis.z]) cube([1000, 1000, 1000], center=true);
}

