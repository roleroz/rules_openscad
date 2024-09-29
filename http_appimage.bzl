"""Library to fetch AppImage files through http and extract them"""

# Repository rule to fetch an AppImage file from a URL and extract it into a
# directory
def _http_appimage_impl(ctx):
    downloaded_file_path = "files/download"
    ctx.download(
        url = [ctx.attr.url],
        output = downloaded_file_path,
        sha256 = ctx.attr.sha256,
        executable = True,
    )
    ctx.execute([downloaded_file_path, "--appimage-extract"])
    ctx.file(
        "WORKSPACE",
        "workspace(name = \"{name}\")".format(name = ctx.name),
    )
    ctx.file(
        "BUILD",
        """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "files",
    srcs = glob(["**"]),
)
"""
    )

http_appimage = repository_rule(
    implementation = _http_appimage_impl,
    attrs = {
        "sha256": attr.string(
            doc = """The expected SHA-256 of the file downloaded

This must match the SHA-256 of the file downloaded. It is a security risk to
omit the SHA-256 as remote files can change. At best omitting this field will
make your build non-hermetic. It is optional to make development easier but
should be set before shipping
""",
        ),
        "url": attr.string(
            doc = """A URL to a file that will be made available to Bazel

This must be a file, http or https URL. Redirections are followed.
Authentication is not supported

More flexibility can be achieved by the urls parameter that allows to specify
alternative URLs to fetch from
""",
        ),
    },
)
