"""Library to define the OpenSCAD versions to fetch per OS

In WORKSPACE world (bazel 6 and earlier) every user of a library needs to load
all the transitive dependencies of all libraries under use, so this file
contains a method that defines the OpenSCAD binary dependencies both for this
repo as well as for any user.
"""

load("//:http_appimage.bzl", "http_appimage")

def define_openscad_versions():
    http_appimage(
        name = "openscad_linux_x86_64",
        url = "https://files.openscad.org/snapshots/OpenSCAD-2024.09.20.ai20452-x86_64.AppImage",
        sha256 = "eb5bfcc0a19df3016e3e00f3e135695020371c24f2a8629bf1e096009bef8a47",
    )
    http_appimage(
        name = "openscad_linux_aarch64",
        url = "https://files.openscad.org/snapshots/OpenSCAD-2023.09.11.ai-aarch64.AppImage",
        sha256 = "84d7bb1c71e14b4e248a84fbe0a4b02f58bcbf5326f0ee81c8a4de3653a3b568",
    )
