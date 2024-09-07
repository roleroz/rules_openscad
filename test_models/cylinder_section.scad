// Provides a section of a cylinder (like a pie), height is in Z, and the
// section is centered on X
//
// The origin of the object is in the center of the cylinder, at the bottom of
// it
module CylinderSection(height, diameter, angle) {
    difference() {
        cylinder(h=height, d=diameter, center=false);
        rotate([0,0,angle/2])
            translate([-(diameter+1)/2,0,-0.5])
                cube([diameter+1,diameter+1,height+1]);
        rotate([0,0,180-angle/2])
            translate([-(diameter+1)/2,0,-0.5])
                cube([diameter+1,diameter+1,height+1]);
    }
}

// Provides roof supports in case you use a CylinderSection to make a cutout on
// a model
//
// The origin of the object is where the origin of the CylinderSection with the
// same parameters would be
module CylinderSectionCutoutRoofSupport(height, diameter, angle) {
    longest_dimension = angle*diameter*PI/720 + height;
    difference() {
        CylinderSection(height, diameter, angle);
        translate([0,0,height])
            rotate([225,0,0])
                cube([diameter/2+1, longest_dimension, longest_dimension]);
    }
}
