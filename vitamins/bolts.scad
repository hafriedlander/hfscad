
// ISO7380 - button head screw

i_shaftD = 0;
i_headD = 1;
i_headZ = 2;

M3_buttonhead = [3, 6, 2.5]; // Made up
M5_buttonhead = [5, 8.6, 2.5]; // Measured

module axleHole(d, z, center=true) {
    cylinder_outer(z, d/2, fn=30, center=center);
}

// A hole for just a bolt shaft
module shaftHole(bolt, shaftL=50, center=true) {
    shaftR = bolt[i_shaftD]/2;
    cylinder_outer(shaftL, shaftR, fn=30, center=center);
}

// Basic two cylinder bolt hole
module boltHole(bolt, shaftL=50, headL=50) {
    shaftR = bolt[i_shaftD]/2;
    headR = bolt[i_headD]/2;

    flipZ() cylinder_outer(shaftL, shaftR, fn=30);
    cylinder_outer(headL, headR, fn=30);
}
