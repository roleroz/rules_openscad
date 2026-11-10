load("@rules_python//python:py_binary.bzl", "py_binary")
load("@rules_python//python:py_library.bzl", "py_library")
load("@rules_python//python:py_test.bzl", "py_test")

py_library(
    name = "scad_utils",
    srcs = ["scad_utils.py"],
)

py_test(
    name = "scad_utils_test",
    legacy_create_init = 0,
    srcs = ["scad_utils_test.py"],
    main = "scad_utils_test.py",
    tags = ["requires-openscad"],
    deps = [
        ":scad_utils",
    ],
)

py_binary(
    name = "scad_unittest",
    legacy_create_init = 0,
    srcs = ["scad_unittest.py"],
    python_version = "PY3",
    visibility = ["//visibility:public"],
    deps = [
        ":scad_utils",
    ],
)

py_binary(
    name = "scad_render",
    legacy_create_init = 0,
    srcs = ["scad_render.py"],
    python_version = "PY3",
    visibility = ["//visibility:public"],
    deps = [
        ":scad_utils",
    ],
)

exports_files(["scad.bzl"])

# The sources of this workspace, for //tests/bazel_versions to copy and build with other Bazel
# versions
filegroup(
    name = "bazel_version_test_sources",
    srcs = glob(
        ["*"],
        exclude = [
            "MODULE.bazel.lock",
            "bazel-*",
        ],
    ),
    visibility = ["//tests/bazel_versions:__pkg__"],
)
