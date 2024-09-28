# OpenSCAD Bazel Rules
This module contains a set of rules compile 3D models written in OpenSCAD code through the bazel build system, this module includes 3 unique rules
- [scad_library](#scad_library): Library to be used by `scad_object` rules to define the 3D model
- [scad_object](#scad_object): Code that defines an specific 3D model. When built, this library generates an STL file
- [scad_test](#scad_test): Unit-testing framework for libraries. Both compares the result of code using the library with golden STLs, but also ensures that invalid uses of the library assert out

## Setup
In order to use these rules in your BUILD files you need to first add this module as a dependency on your `MODULES.bazel` or `WORKSPACE` file, and then add the rules to your `BUILD` file

### Add the module dependency

#### Modify your MODULE.bazel file (if using bazel 7)
Just add the following line to your `MODULES.bazel` file
```
bazel_dep(name="rules_openscad", version="0.1")
```

#### Modify your WORKSPACE file (if using bazel 6)
Just add the following line to your `WORKSPACE` file
```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "rules_openscad",
    remote = "https://github.com/roleroz/rules_openscad.git",
    tag = "v0.2",
)

load("@rules_openscad//:openscad_files.bzl", "define_openscad_versions")
define_openscad_versions()
```

### Load the rule definitions on your BUILD files
Once you have added the dependency to your bazel module, you need to add the following code to the `BUILD` file on which you want to use the rules
```
load(
    "@rules_openscad//:scad.bzl",
    "scad_library",
    "scad_object",
    "scad_test",
)
``` 
You only need to load the specific rules that you want to use

After this, you can use the rules the same way that you would use any other Bazel rule

## Rules reference

### scad_library
Create a 3D library to wrap OpenSCAD code to be linked by other libraries or objects

|Parameter|Type|Description
|-|-|-
|srcs|list[file]|List of files that compile to generate this library
|deps|list[target]|Other libraries this library depends on

#### Example library
```
scad_library(
    name = "hollow_cylinder",
    srcs = ["hollow_cylinder.scad"],
    deps = [
        ":some_library",
    ],
    visibility = ["//visibility:public"],
)
```

### scad_object
Create a 3D object based on the provided code and libraries

|Parameter|Type|Description
|-|-|-
|srcs|list[file]|List of files that compile to generate this object
|deps|list[target]|List of libraries this object depends on

#### Example object
```
scad_object(
    name = "hollow_cylinder_obj",
    srcs = ["hollow_cylinder_obj.scad"],
    deps = [":hollow_cylinder"],
)
```

### scad_test
Test for 3D objects and libraries

The test works by compiling the code provided in the tests attribute, and
comparing it with the provided golden STL file. If the 2 objects are equal then
the test passes, if they aren't then the test fails. 2 objects (A and B) are
defined equal if A-B is empty (B includes A) and B-A is empty (A includes B)

The test also checks that assertions are triggered for all the code provided in
the assertions list

|Parameter|Type|Description
|-|-|-
|library_under_test|label|Library that will be imported when compiling any code under test
|tests|dict[label][string]|List of testcases. The key is the filename of the golden STL for this testcase, and the value is the code under test (which object will be compiled) without the library under test being imported (that's done by the framework)<br/><br/>The test will fail if any of the code snippets under test create a result that is different from the golden STL for that testcase</p>
|assertions|list[string]|List of code snippets that are expected to fail an assertion. The test will fail if any of these fail to trigger an assertion


#### Example test
```
scad_test(
    name = "hollow_cylinder_test",
    assertions = [
        "HollowCylinder(length=10,external_diameter=2,internal_diameter=5,wall_thickness=3)",
        "HollowCylinder(length=10,external_diameter=2)",
        "HollowCylinder(length=10,internal_diameter=5)",
        "HollowCylinder(length=10,wall_thickness=3)",
        "HollowCylinder(length=10)",
    ],
    library_under_test = ":hollow_cylinder",
    tests = {
        "testdata/hollow_cylinder/ed_id.stl": "HollowCylinder(length=10,external_diameter=3,internal_diameter=1)",
        "testdata/hollow_cylinder/ed_wt.stl": "HollowCylinder(length=10,external_diameter=3,wall_thickness=0.2)",
        "testdata/hollow_cylinder/id_wt.stl": "HollowCylinder(length=10,internal_diameter=5,wall_thickness=3)",
    },
)
```

## Usage

### Render an object into an STL
`bazel build //path/to:object` will render that object as an STL and store it in the `bazel-bin` directory, at `bazel-bin/path/to/object.stl`