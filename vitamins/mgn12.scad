include <../utils.scad>;
include <../cs.scad>;
include <../shapes.scad>;
include <bolts.scad>;

d=1;
r=1;

// https://www.hiwin.de/temp/images/1259/610-500-1-pdf/Zchng_Abmessungen_MGN_XX.jpg

mgn12_H=13;
mgn12_H1=3;
mgn12_N=7.5;
mgn12_W=27;
mgn12_B=20;
mgn12_B1=3.5;
mgn12h_C=20;
mgn12h_L1=32.4;
mgn12h_L=45.4;
mgn12_Gn=0.8*d;
mgn12_bolt=[3, 3.5];

mgn12_H2=2.5;
mgn12_WR=12;
mgn12_HR=8;
mgn12_D=6*d;
mgn12_h=4.5;
mgn12_d=3.5*d;
mgn12_P=25;
mgn12_E=10;

// Bolt = M3x3.5
// Another bolt = M3x8

mgn12_ch = mgn12_H - mgn12_H1;
mgn12_sw = mgn12_B1*2;

mgn12_mountpoints = [    
    for (x = [-mgn12_B/2, mgn12_B/2], y = [-mgn12h_C/2, mgn12h_C/2])
    [x, y, mgn12_ch]
];

module MGN12Body() {
    mgn_xo = mgn12_W/2 - mgn12_sw/2;
    symmetricX() color([0.7, 0.7, 0.7]) t(mgn_xo*X) cube2([mgn12_sw, mgn12h_L1, mgn12_ch], center=-Z);

    color("grey") cube2([mgn12_W - mgn12_sw*2, mgn12h_L1, mgn12_ch-0.5], center=-Z);

    endL=(mgn12h_L - mgn12h_L1)/2;
    endY=mgn12h_L1/2 + endL/2;

    symmetricY() color("red") t(endY*Y) cube2([mgn12_W, endL, mgn12_ch-0.5], center=-Z);
}

module MGN12MountingHoles() {
    for (x = [-mgn12_B/2, mgn12_B/2]) {
        for (y = [-mgn12h_C/2, mgn12h_C/2]) {
            t([x, y]) axleHole(mgn12_bolt[0], mgn12_bolt[1] + _e);
        }
    }
}

module MGN12Carriage() {
    difference() {
        MGN12Body();
        h = mgn12_ch - mgn12_bolt[1]/2;
        t(h*Z) MGN12MountingHoles();
        t(-mgn12_H1*Z) cube2([mgn12_WR, mgn12h_L + _e, mgn12_HR], center=-Z);
    }
}

MGN12C_CenterBase = globalCS;
MGN12C_CenterTop = newCS([0, 0, mgn12_ch]);
MGN12C_CenterRail = newCS([0, 0, mgn12_HR - mgn12_H1]);

MGN12R_CarriageBottom = newCS([0, 0, mgn12_H1]);
MGN12R_CenterTop = newCS([0, 0, mgn12_HR]);
MGN12R_CenterBottom = newCS([0, 0, 0]);

mgn12_ballrun=1.2*d;
mgn12_ballz=1.792+mgn12_ballrun/2;
mgn12_ballcut=[1.12, 0, .61];

module MGN12Rail(length=200) {
    difference() {
        cube2([mgn12_WR, length, mgn12_HR], center=-Z);
        
        // Ball run
        symmetricX() t([mgn12_WR/2, 0, mgn12_HR - mgn12_ballz]) {
            r(90*X) cylinder(d=mgn12_ballrun, h=length+_e, center=true, $fn=20);
            cube2([mgn12_ballcut.x, length+_e, mgn12_ballcut.z], center=X);
        }

        // Bolt holes
        for (b = [mgn12_E : mgn12_P : length]) {
            t((-length/2 + b)*Y) {
                t(mgn12_HR/2*Z) axleHole(mgn12_d, mgn12_HR + _e);
                t((mgn12_HR-mgn12_h/2)*Z) axleHole(mgn12_D, mgn12_h + _e);
            }
        }
    }
}

MGN12_Test=true;
if (MGN12_Test) {
    MGN12Carriage();
    drawCS(MGN12C_CenterTop, "MGN12C_CenterTop");
    drawCS(MGN12C_CenterRail, "MGN12C_CenterRail");
    inCS(innerCS=MGN12R_CenterTop, outerCS=MGN12C_CenterRail) MGN12Rail();
}