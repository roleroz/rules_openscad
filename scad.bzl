"""Library used to handle OpenSCAD files in Bazel

There are 3 rules in this library:
- scad_library(): Create a library object that other libraries or objects can
  link to
- scad_object(): Create a 3D object that can be rendered
- scad_test(): Test your 3D object by comparing it with a golden model that is
  submitted into git. This rule also creates an implicit rule used to render the
  golden model for ease of updating with changes to the model
"""

srcs_attrs = attr.label_list(
    mandatory = True,
    allow_empty = False,
    allow_files = [".scad"],
    doc = "Filenames for the files that are included in this rule",
)

deps_attrs = attr.label_list(
    mandatory = False,
    allow_empty = True,
    providers = [DefaultInfo],
    doc = "Other libraries that the files on this rule depend on",
)

def _scad_library_impl(ctx):
    files = depset(ctx.files.srcs, transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps])
    return [DefaultInfo(
        files = files,
        runfiles = ctx.runfiles(
            files = files.to_list(),
            collect_data = True,
        ),
    )]

scad_library = rule(
    implementation = _scad_library_impl,
    attrs = {
        "srcs": srcs_attrs,
        "deps": deps_attrs,
    },
    doc = """
Create a 3D library to be linked by other libraries or objects

Args:
    srcs: (list[file]) List of files that compile to generate this library
    deps: (list[target]) Other libraries this library depends on
""",
)

def _scad_object_impl(ctx):
    stl_output = ctx.actions.declare_file(ctx.label.name + ".stl")
    stl_inputs = ctx.files.srcs
    deps = []
    for one_transitive_dep in [dep[DefaultInfo].files for dep in ctx.attr.deps]:
        deps += one_transitive_dep.to_list()
    ctx.actions.run_shell(
        outputs = [stl_output],
        inputs = stl_inputs + deps,
        command = "openscad --export-format=stl -o {} {}".format(
            stl_output.path,
            " ".join([f.path for f in stl_inputs]),
        ),
    )
    files = depset(ctx.files.srcs + [stl_output], transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps])
    return [DefaultInfo(
        files = files,
        runfiles = ctx.runfiles(
            files = files.to_list(),
            collect_data = True,
        ),
    )]

scad_object = rule(
    implementation = _scad_object_impl,
    attrs = {
        "srcs": srcs_attrs,
        "deps": deps_attrs,
    },
    doc = """
Create a 3D object based on the provided code and libraries

Args:
    srcs: (list[file]) List of files that compile to generate this object
    deps: (list[target]) List of libraries this object depends on
""",
)

def scad_test(
        name,
        file_under_test,
        tests,
        deps,
        assertions = []):
    """Test for 3D objects and libraries (adds implicit rule to render results)

    The test works by compiling the provided code, and comparing it with the
    provided golden STL file. If the 2 objects are equal then the test passes,
    if they aren't then the test fails. 2 objects (A and B) are defined equal if
    A-B (B includes A) is empty and B-A is empty (A includes B)

    There is an implicit rule created (<name>_render) that will compile all the
    testcases and provide the results as STL files, so the golden STL files can
    be updated in case of a change in the library under test

    Args:
        name: (string) Name for this rule (name of the test). The implicit
            render rule is named <name>_render
        file_under_test: (string) Library name that will be linked when
            compiling any code under test
        tests: (map[string]->string) List of testcases. The key is the code
            under test (which object will be compiled) without the library under
            test being imported (that's done by the  framework), and the value
            is the filename of the golden STL for the. The test will fail if any
            of the code snippets under test create a result that is different
            from the golden STL for that testcase
        deps: (list[target]) List of libraries required by this test. Normally
            only the one including the code under test, as that library will
            link on its dependencies
        assertions: (list[string]) List of code snippets that are expected to
            fail an assertion. The test will fail if any of these don't fail
            their assertions
    """

    # Get a base label to create all other relative ones to this
    test_label = Label("%s//%s:%s" % (native.module_name(),
                                      native.package_name(),
                                      name))

    print(test_label)

    deps_label = []
    for dep in deps:
        deps_label.append(test_label.relative(dep))
    expected_stls_label = []
    expected_stls_filenames = []
    testcases = []
    rendercases = []
    for scad_cmd, expected_stl in tests.items():
        scad_cmd = scad_cmd.replace("(", "\\(").replace(")", "\\)")
        expected_stl_label = test_label.relative(expected_stl)
        testcases.append("--testcases %s#$(rootpath %s)" % (scad_cmd, expected_stl_label))
        rendercases.append("--render_cases %s#%s" % (scad_cmd, expected_stl))
        if not expected_stl_label in expected_stls_label:
            expected_stls_label.append(expected_stl_label)
            expected_stls_filenames.append(expected_stl)
    file_under_test_label = test_label.relative(file_under_test)
    assertions_flag = []
    for assertion in assertions:
        assertions_flag.append("--assertion_check %s" % assertion)

    native.sh_test(
        name = name,
        size = "medium",
        srcs = ["//:scad_unittest_script.sh"],
        data = expected_stls_label + [Label("//:scad_unittest"), file_under_test_label] + deps_label,
        args = [
            "--scad_file_under_test $(rootpath %s)" % file_under_test_label,
            " ".join(testcases),
            " ".join(assertions_flag),
            "--scad_code_file scad.code",
            "--render_stl render.stl",
            "--new_parts_stl new_parts.stl",
            "--missing_parts_stl missing_parts.stl",
        ],
    )
