load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Checks that the rules build and pass their tests with each supported Bazel version, both in
# the main workspace and as a dependency of test_models. Each downloads Bazel and its dependencies,
# hence `live`; `manual` keeps them out of `bazel test //...`, and with that out of the nested
# Bazel's own wildcard runs, so they can never end up running themselves.
#
# This is a package of its own because it needs rules_shell, a dev dependency that consumers of
# rules_openscad don't see: the root package is loaded by every consumer and cannot load it.
SUPPORTED_BAZEL_MAJOR_VERSIONS = [7, 8, 9]

[
    sh_test(
        name = "bazel_%s_test" % version,
        size = "enormous",
        srcs = ["test_bazel_version.sh"],
        args = ["%s.x" % version],
        data = [
            "//:bazel_version_test_sources",
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
