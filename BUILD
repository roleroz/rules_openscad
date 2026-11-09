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

# Checks that the rules build and pass their tests with each supported Bazel version, both in
# this workspace and as a dependency of test_models. Each downloads Bazel and its dependencies,
# hence `live`; `manual` keeps them out of `bazel test //...`, and with that out of the nested
# Bazel's own wildcard runs, so they can never end up running themselves.
SUPPORTED_BAZEL_MAJOR_VERSIONS = [7, 8]

filegroup(
    name = "bazel_version_test_sources",
    srcs = glob(
        ["*"],
        exclude = [
            "MODULE.bazel.lock",
            "bazel-*",
        ],
    ),
)

[
    sh_test(
        name = "bazel_%s_test" % version,
        size = "enormous",
        srcs = ["test_bazel_version.sh"],
        args = ["%s.x" % version],
        data = [
            ":bazel_version_test_sources",
            "@test_models_src//:files",
        ],
        # The nested Bazel needs the user's bazelisk and OpenSCAD, and a HOME to cache bazelisk's
        # downloads in
        env_inherit = [
            "HOME",
            "PATH",
            "USER",
        ],
        tags = [
            # No cached results: the outcome depends on the network and on the installed tools
            "external",
            "live",
            "local",
            "manual",
        ],
    )
    for version in SUPPORTED_BAZEL_MAJOR_VERSIONS
]

test_suite(
    name = "bazel_versions_test",
    tags = ["manual"],
    tests = [
        ":bazel_%s_test" % version
        for version in SUPPORTED_BAZEL_MAJOR_VERSIONS
    ],
)
