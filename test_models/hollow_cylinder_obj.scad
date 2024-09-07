use <hollow_cylinder.scad>

$fn=50;
// HollowCylinder(length=10,external_diameter=3,internal_diameter=1); // testdata/hollow_cylinder/ed_id.stl
// HollowCylinder(length=10,external_diameter=3,wall_thickness=0.2); // testdata/hollow_cylinder/ed_wt.stl
HollowCylinder(length=10,internal_diameter=5,wall_thickness=3); // testdata/hollow_cylinder/id_wt.stl
