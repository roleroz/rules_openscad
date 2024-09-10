load(
    "@openscad_rules//:scad.bzl",
    "scad_library",
    "scad_object",
    "scad_test",
)

scad_library(
    name = "cylinder_section",
    srcs = ["cylinder_section.scad"],
    visibility = ["//visibility:public"],
)

scad_object(
    name = "cylinder_section_obj",
    srcs = ["cylinder_section_obj.scad"],
    deps = [":cylinder_section"],
)

scad_test(
    name = "cylinder_section_test",
    library_under_test = ":cylinder_section",
    tests = {
        "testdata/cylinder_section/cylinder_section.stl": "CylinderSection(height=5,diameter=20,angle=45)",
    },
)

scad_library(
    name = "hardware",
    srcs = ["hardware.scad"],
    visibility = ["//visibility:public"],
)

scad_object(
    name = "hardware_obj",
    srcs = ["hardware_obj.scad"],
    deps = [":hardware"],
)

scad_test(
    name = "hardware_test",
    library_under_test = ":hardware",
    tests = {
        "testdata/hardware/m2_nut.stl": "M2Nut(extra_thickness=1)",
    },
)

scad_library(
    name = "hollow_cylinder",
    srcs = ["hollow_cylinder.scad"],
    visibility = ["//visibility:public"],
)

scad_object(
    name = "hollow_cylinder_obj",
    srcs = ["hollow_cylinder_obj.scad"],
    deps = [":hollow_cylinder"],
)

scad_test(
    name = "hollow_cylinder_test",
    assertions = [
        "HollowCylinder(length=10,external_diameter=2,internal_diameter=5,wall_thickness=3)",
        "HollowCylinder(length=10,external_diameter=2)",
        "HollowCylinder(length=10,internal_diameter=5)",
        "HollowCylinder(length=10,wall_thickness=3)",
        "HollowCylinder(length=10)",
    ],
    library_under_test = ":hollow_cylinder",
    tests = {
        "testdata/hollow_cylinder/ed_id.stl": "HollowCylinder(length=10,external_diameter=3,internal_diameter=1)",
        "testdata/hollow_cylinder/ed_wt.stl": "HollowCylinder(length=10,external_diameter=3,wall_thickness=0.2)",
        "testdata/hollow_cylinder/id_wt.stl": "HollowCylinder(length=10,internal_diameter=5,wall_thickness=3)",
    },
)
