# The rule reference. It lives apart from the root package, which every
# user of the module loads, because stardoc is a dev dependency.
load("@stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "docs",
    out = "scad.md",
    input = "//:scad.bzl",
    tags = ["manual"],
)
