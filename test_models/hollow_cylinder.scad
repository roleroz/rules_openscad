// Provides a pipe (a hollow cylinder) lengthwise over Z
//
// 2 and only 2 of the following parameters must be set, or the module will
// assert:
// - external_diameter
// - internal_diameter
// - wall_thickness
//
// The origin of this object is at the center on both X and Y, and at the bottom
// in Z
module HollowCylinder(
  length,
  external_diameter=-1,
  internal_diameter=-1,
  wall_thickness=-1
) {
  assert(
    external_diameter == -1 ||
      internal_diameter == -1 ||
      wall_thickness == -1,
    str(
      "Only 2 of the 3 parameters (external_diameter, internal_diameter, ",
      "wall_thickness) can be used at once"));
  if (external_diameter == -1) {
    assert(
      internal_diameter >= 0 && wall_thickness >= 0,
      str(
        "2 of the 3 parameters (external_diameter, internal_diameter, ",
        "wall_thickness) need to be set"));
  } else if (internal_diameter == -1) {
    assert(
      external_diameter >= 0 && wall_thickness >= 0,
      str(
        "2 of the 3 parameters (external_diameter, internal_diameter, ",
        "wall_thickness) need to be set"));
  }

  id = internal_diameter == -1?
    external_diameter - 2 * wall_thickness:
    internal_diameter;
  ed = external_diameter == -1?
    internal_diameter + 2 * wall_thickness:
    external_diameter;
  difference() {
    cylinder(h=length, d=ed, center=false);
    translate([0,0,-1]) cylinder(h=length+2, d=id, center=false);
  }
}
