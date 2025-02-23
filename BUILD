load("@stardoc//stardoc:stardoc.bzl", "stardoc")

py_library(
    name = "scad_utils",
    srcs = ["scad_utils.py"],
)

py_binary(
    name = "scad_unittest",
    srcs = ["scad_unittest.py"],
    python_version = "PY3",
    visibility = ["//visibility:public"],
    deps = [
        ":scad_utils",
    ],
)

py_binary(
    name = "scad_render",
    srcs = ["scad_render.py"],
    python_version = "PY3",
    visibility = ["//visibility:public"],
    deps = [
        ":scad_utils",
    ],
)

stardoc(
    name = "docs",
    input = "scad.bzl",
    out = "scad.md",
    tags = ["manual"],
)
