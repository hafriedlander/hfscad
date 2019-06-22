include <utilities.scad>;

vslotLocatorShape=[[0,0],[3,3],[9-3,3],[9,0]];

module vslotLocator(length, lChamfer = false, rChamfer = false) {
    box=10; hyp=sqrt(box*box+box*box); halfHyp=hyp/2;;

    difference () {
        linear_extrude(length) polygon(vslotLocatorShape);
        if (lChamfer) translate([0, halfHyp, length-halfHyp]) rotate([45, 0, 0]) cube([box, box, box]);
        if (rChamfer) translate([0, halfHyp, -halfHyp]) rotate([45, 0, 0]) cube([box, box, box]);
    }

}

module vslotGrid(grid) {
    // Reverse the grid, since we're building bottom up
    rGrid = [ for (i = [len(grid) : -1 : 1]) grid[i-1] ];

    for (z = [0: 1: len(rGrid)-1]) {
        row=rGrid[z];
        for (x = [0: 1: len(row)-1]) {
            slot=row[x];
            if (slot == "x") {
                translate([20*x, 0, 20*z]) 
                    translate([0, 0, 9 + (20-9)/2]) 
                    rotate([0, 90, 0]) 
                    vslotLocator(20, row[x+1] != "x", x == 0 || row[x-1] != "x");
            }
            if (slot == "z") {
                translate([20*x, 0, 20*z]) 
                    translate([(20-9)/2, 0, 0]) 
                    vslotLocator(20, rGrid[z+1][x] != "z", z == 0 || rGrid[z-1][x] != "z");
            }

        }
    }
}

module boltGrid(grid, slotBolt=4, slotBoltHead=7, slotBoltOffset=4) {
    rGrid = [ for (i = [len(grid) : -1 : 1]) grid[i-1] ];

    flipY()
    for (z = [0: 1: len(rGrid)-1]) {
        row=grid[z];
        for (x = [0: 1: len(row)-1]) {
            if (row[x]) {
                // The bolt hole
                translate([x*20+10, 0, z*20+10]) 
                    translate([0, slotBoltOffset, 0]) 
                    boltHole(slotBolt, slotBoltHead, 50, 50);

                // The locator cutout
                translate([x*20+10-7.5, -3.1, z*20+10+7.5])
                    rotate([-90, 0, 0])
                    truncatedPyramid(15, 15, 9, 3.1);
            }
        }
    }
}

use <MCAD/shapes.scad>;

// Adjusted version of openscad-openbuild/vslot
module vslotCutaway(length=50, epsilon=0.15, surfaceEpsilon=false, complex=false) {
  size=20;
  cutext=[[0.00, 5.43], [4.57, 10.00], [4.57, 10.10], [-4.57, 10.10], [-4.57, 10.00]];
  cutint=[[-2.84, 3.90], [-0.21, 3.90], [0.00, 3.70], [0.21, 3.90], [2.84, 3.90], [5.50, 6.56], [5.50, 8.20], [2.89, 8.20], [2.89, 9.20], [-2.89, 9.20], [-2.89, 8.20], [-5.50, 8.20], [-5.50, 6.56]];

  sE = surfaceEpsilon ? surfaceEpsilon*2 : epsilon * 2;

  module profile() {
    translate([0, 0, length/2]) difference() {
      roundedBox(size+sE, size+sE, length, 1.8);
      total_length = length+10;
      for (angle=[0:90:270]) {
        translate([0, 0, -(total_length)/2]) linear_extrude(total_length) rotate(angle) translate([0, epsilon*1.4, 0]) polygon(cutext);
        translate([0, 0, -(total_length)/2]) linear_extrude(total_length) rotate(angle) offset(delta=-epsilon) polygon(cutext);
        if (complex) translate([0, 0, -(total_length)/2]) linear_extrude(total_length) rotate(angle) offset(delta=-epsilon) polygon(cutint);
      }
    }
  }

  profile();
}

module test_vslotGrid() {
    //!vslotGrid([["x"]]);
    !vslotGrid([["x", "x", "z"], [false, false, "z"], ["z", false, "x"]]);
}


