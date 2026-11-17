load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_openscad//:scad.bzl", "scad_library", "scad_object", "scad_test")
load("@rules_openscad//:toolchain.bzl", "openscad_toolchain")
load(
    ":toolchain_test.bzl",
    "fake_openscad",
    "test_runs_toolchain_test",
    "uses_host_test",
    "uses_toolchain_test",
    "with_file_toolchain",
)

fake_openscad(name = "fake_openscad")

openscad_toolchain(
    name = "fake_toolchain_impl",
    openscad = ":fake_openscad",
)

# Registered only by the tests below, with --extra_toolchains.
toolchain(
    name = "fake_toolchain",
    toolchain = ":fake_toolchain_impl",
    toolchain_type = "@rules_openscad//:toolchain_type",
)

# A toolchain whose openscad is a file, with a data file it checks for.
openscad_toolchain(
    name = "file_toolchain_impl",
    data = ["fake_openscad_data.txt"],
    openscad = "fake_openscad.sh",
)

toolchain(
    name = "file_toolchain",
    toolchain = ":file_toolchain_impl",
    toolchain_type = "@rules_openscad//:toolchain_type",
)

scad_object(
    name = "cube",
    srcs = ["cube.scad"],
    tags = ["manual"],
)

uses_toolchain_test(
    name = "uses_toolchain_test",
    target_under_test = ":cube",
)

uses_host_test(
    name = "uses_host_test",
    target_under_test = ":cube",
)

# The cube, built for real with file_toolchain: its action runs the fake
# openscad, which fails unless its data file is in the sandbox.
with_file_toolchain(
    name = "cube_with_file_toolchain",
    target = ":cube",
)

build_test(
    name = "file_toolchain_build_test",
    targets = [":cube_with_file_toolchain"],
)

scad_library(
    name = "cube_lib",
    srcs = ["cube.scad"],
)

scad_test(
    name = "cube_test",
    library_under_test = ":cube_lib",
    tags = ["manual"],
    # Only analyzed: the golden need not match.
    tests = {"cube.stl": "cube(10)"},
)

test_runs_toolchain_test(
    name = "test_runs_toolchain_test",
    target_under_test = ":cube_test",
)
