py_library(
    name = "scad_utils",
    srcs = ["scad_utils.py"],
)

py_test(
    name = "scad_utils_test",
    srcs = ["scad_utils_test.py"],
    main = "scad_utils_test.py",
    tags = ["requires-openscad"],
    deps = [
        ":scad_utils",
    ],
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

exports_files(["scad.bzl"])
