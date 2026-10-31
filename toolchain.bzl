"""An OpenSCAD toolchain, so builds can use a pinned OpenSCAD instead of the host's.

The rules of scad.bzl use the toolchain of type `@rules_openscad//:toolchain_type`
when one is registered, and the `openscad` on the host's PATH otherwise.
"""

OPENSCAD_TOOLCHAIN_TYPE = Label("//:toolchain_type")

OpenscadInfo = provider(
    doc = "An OpenSCAD binary and what it needs at run time.",
    fields = {
        "openscad": "FilesToRunProvider: the openscad executable.",
        "data": "depset of File: what it reads at run time, for actions.",
        "runfiles": "runfiles: the executable and what it reads, for tests.",
    },
)

def _openscad_toolchain_impl(ctx):
    openscad = ctx.attr.openscad[DefaultInfo]
    runfiles = ctx.runfiles(files = [ctx.executable.openscad] + ctx.files.data)
    runfiles = runfiles.merge(openscad.default_runfiles)
    for d in ctx.attr.data:
        runfiles = runfiles.merge(d[DefaultInfo].default_runfiles)
    return [platform_common.ToolchainInfo(
        openscad = OpenscadInfo(
            openscad = openscad.files_to_run,
            data = depset(ctx.files.data),
            runfiles = runfiles,
        ),
    )]

openscad_toolchain = rule(
    implementation = _openscad_toolchain_impl,
    attrs = {
        "openscad": attr.label(
            mandatory = True,
            executable = True,
            allow_files = True,
            cfg = "exec",
            doc = "The openscad executable: a file, or a rule that makes one.",
        ),
        "data": attr.label_list(
            allow_files = True,
            cfg = "exec",
            doc = "Files openscad needs at run time: its libraries, fonts and the like.",
        ),
    },
    doc = """
An OpenSCAD toolchain. Declare one, and register it, to build with a pinned
OpenSCAD instead of the one on the host's PATH:

```
load("@rules_openscad//:toolchain.bzl", "openscad_toolchain")

openscad_toolchain(
    name = "my_openscad_impl",
    openscad = "@my_openscad//:bin/openscad",
    data = ["@my_openscad//:all_files"],
)

toolchain(
    name = "my_openscad",
    # Where the binary runs, such as Linux x86_64.
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":my_openscad_impl",
    toolchain_type = "@rules_openscad//:toolchain_type",
)
```

and in MODULE.bazel, `register_toolchains("//path/to:my_openscad")`.

Where no registered toolchain matches the execution platform, the rules
fall back to the host's `openscad`, as they did before toolchains. The
toolchain's binary is built for the execution platform; `scad_test` runs it
there too, so a setup that runs tests on another platform than it builds
on needs a toolchain for that one.
""",
)
