// Library with hardware, so we can use them to create holes for them in models

// An M2 nut. You can provide extra thickness, so when you remove it from your
// model, it takes the boundary layer with it
module M2Nut(extra_thickness=0) {
    cylinder(h=1.6+extra_thickness, d=4.65, $fn=6);
}

// Returns the size of a shielded RJ45 connector, so it's consistently drawn in
// all enclosures. The returned values are [width, height, depth]
function RJ45ConnectorSize() = [16.5, 17.2, 16.4];

// Returns the size of the face of a shielded RJ45 connector, so it's
// consistently drawn in all enclosures. The returned values are [width, height]
function RJ45ConnectorFaceSize() = [for (i=[0,1]) RJ45ConnectorSize()[i]];