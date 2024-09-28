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

alias(
    name = "openscad",
    actual = select({
        "@bazel_tools//src/conditions:linux_x86_64": "@openscad_linux_x86_64//:files",
        "@bazel_tools//src/conditions:linux_aarch64": "@openscad_linux_aarch64//:files",
        # Add the following lines when we support MacOS and Windows
        # "@bazel_tools//src/conditions:darwin" : ":openscad_darwin",
        # "@bazel_tools//src/conditions:windows" : ":openscad_windows",
    }),
    visibility = ["//visibility:public"],
)
