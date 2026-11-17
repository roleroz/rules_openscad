"""Tests of the optional OpenSCAD toolchain."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _fake_openscad_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "#!/bin/sh\nexit 1\n", is_executable = True)
    return [DefaultInfo(executable = out)]

# An executable that stands in for openscad, for the analysis tests.
fake_openscad = rule(implementation = _fake_openscad_impl, executable = True)

_FAKE = str(Label("//toolchain:fake_toolchain"))
_FILE = str(Label("//toolchain:file_toolchain"))

def _with_toolchain_impl(ctx):
    env = analysistest.begin(ctx)
    actions = [a for a in analysistest.target_actions(env) if a.mnemonic == "OpenScad"]
    asserts.equals(env, 1, len(actions), "one OpenScad action")
    if actions:
        asserts.true(env, actions[0].argv[0].endswith("toolchain/fake_openscad"),
                     "the action runs the toolchain's openscad, not %s" % actions[0].argv[0])
        asserts.equals(env, ["--export-format=stl", "-o"], actions[0].argv[1:3])
    return analysistest.end(env)

uses_toolchain_test = analysistest.make(
    _with_toolchain_impl,
    config_settings = {"//command_line_option:extra_toolchains": [_FAKE]},
)

def _without_toolchain_impl(ctx):
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)
    asserts.false(env, "OpenScad" in [a.mnemonic for a in actions],
                  "no toolchain: the host's openscad, as before")
    stl = [a for a in actions if [o for o in a.outputs.to_list() if o.extension == "stl"]]
    asserts.equals(env, 1, len(stl), "one action writes the STL")
    if stl:
        asserts.true(env, "openscad --export-format=stl" in " ".join(stl[0].argv),
                     "the STL comes from the host's openscad: %s" % stl[0].argv)
    return analysistest.end(env)

uses_host_test = analysistest.make(
    _without_toolchain_impl,
    # Whatever the command line registers, none here.
    config_settings = {"//command_line_option:extra_toolchains": []},
)

def _file_toolchain_transition_impl(_settings, _attr):
    return {"//command_line_option:extra_toolchains": [_FILE]}

_file_toolchain_transition = transition(
    implementation = _file_toolchain_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:extra_toolchains"],
)

def _with_file_toolchain_impl(ctx):
    target = ctx.attr.target[0] if type(ctx.attr.target) == "list" else ctx.attr.target
    return [DefaultInfo(files = target[DefaultInfo].files)]

# Builds target with file_toolchain registered.
with_file_toolchain = rule(
    implementation = _with_file_toolchain_impl,
    attrs = {"target": attr.label(cfg = _file_toolchain_transition)},
)

def _test_runs_toolchain_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    runfiles = [f.short_path for f in target[DefaultInfo].default_runfiles.files.to_list()]
    for want in ["toolchain/fake_openscad.sh", "toolchain/fake_openscad_data.txt"]:
        asserts.true(env, want in runfiles, "%s is not in scad_test's runfiles: %s" % (want, runfiles))
    script = [a for a in analysistest.target_actions(env) if a.mnemonic == "FileWrite"]
    asserts.equals(env, 1, len(script), "one script")
    if script:
        asserts.true(env, "--openscad_command './toolchain/fake_openscad.sh'" in script[0].content,
                     "scad_test runs the toolchain's openscad by its path: %s" % script[0].content)
    return analysistest.end(env)

test_runs_toolchain_test = analysistest.make(
    _test_runs_toolchain_impl,
    config_settings = {"//command_line_option:extra_toolchains": [_FILE]},
)
