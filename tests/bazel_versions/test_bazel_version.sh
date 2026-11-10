#!/usr/bin/env bash
# Builds and tests this repo with one Bazel version, both as the main workspace and as a
# dependency of the consumer workspace in test_models/.
#
# Usage: test_bazel_version.sh <version as understood by bazelisk, e.g. 7.x>
#
# Runs as a Bazel test (see BUILD), so it works on a copy of the sources taken from its runfiles
# and starts nested Bazel instances whose output is kept in the test's temporary directory.
set -euo pipefail

{
    # The nested Bazel works on a copy of the workspace that contains this test. The copy leaves
    # out tests/ and the nested Bazel only builds :all and runs the tests of test_models, so
    # nothing in there can start this test again. If something ever did, it would start another
    # nested Bazel, and so on forever. Refuse instead.
    if [[ -n "${RULES_OPENSCAD_NESTED_BAZEL_TEST:-}" ]]; then
        echo "ERROR: this test is being run from inside itself" >&2
        exit 1
    fi
    export RULES_OPENSCAD_NESTED_BAZEL_TEST=1

    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <bazel version, e.g. 7.x>" >&2
        exit 1
    fi
    requested_version="$1"
    # bazelisk reads this to pick the Bazel to run
    export USE_BAZEL_VERSION="$requested_version"

    # Call bazelisk by name, never `bazel`: the Bazel running this test puts its own binary first
    # on the PATH it passes down, so `bazel` would be that very version and ignore
    # USE_BAZEL_VERSION.
    if ! command -v bazelisk > /dev/null; then
        echo "ERROR: bazelisk is needed to pick the Bazel version, but is not on the PATH" >&2
        exit 1
    fi

    # Where Bazel put the sources of this test and of the test_models repo (see MODULE.bazel)
    srcdir="${TEST_SRCDIR:?must run as a Bazel test}"
    root_src="${srcdir}/${TEST_WORKSPACE:?}"
    # The directory name of an external repo depends on the Bazel version running this test
    # ("_main~_repo_rules~test_models_src" or "+_repo_rules+test_models_src"), so look it up
    # rather than hardcode it.
    test_models_src=""
    for candidate in "${srcdir}"/*test_models_src; do
        [[ -d "$candidate" ]] || continue
        test_models_src="$candidate"
    done
    if [[ -z "$test_models_src" ]]; then
        echo "ERROR: test_models_src not found in the runfiles of this test" >&2
        exit 1
    fi

    # Work on a writable copy; the runfiles are symlinks into the real source tree
    work="${TEST_TMPDIR:?}/work"
    mkdir -p "${work}/test_models"
    cp -rL "${root_src}/." "${work}/"
    cp -rL "${test_models_src}/." "${work}/test_models/"
    # tests/ holds this test and its launcher; the nested workspace is the sources without it
    rm -rf "${work}/tests"

    # Keep the nested Bazel's outputs (and its servers) inside the test's own directory so that
    # they cannot touch or be confused with the Bazel that is running this test.
    output_user_root="${TEST_TMPDIR}/bazel_output_user_root"

    # The nested Bazel starts with an empty cache of downloads, which makes it refetch everything
    # from the network on every run and fail whenever a host is down. Share the user's own
    # repository cache instead (Bazel's default location on Linux): it is keyed by content hash,
    # so what the nested Bazel finds there is exactly what it asked for.
    repository_cache="${HOME:?}/.cache/bazel/_bazel_${USER:?}/cache/repos/v1"

    run_bazel() {
        bazelisk "--output_user_root=${output_user_root}" "$@"
    }

    shutdown_servers() {
        local dir
        for dir in "${work}" "${work}/test_models"; do
            (cd "$dir" && run_bazel shutdown) || true
        done
    }
    trap shutdown_servers EXIT

    # --version is not a startup option, so it cannot be combined with the ones run_bazel adds
    version_output=$(cd "$work" && bazelisk --version)
    echo "Testing with ${version_output}"
    # bazelisk silently falls back to .bazelversion or the latest release if it does not
    # understand the request
    if [[ "$version_output" != "bazel ${requested_version%.x}."* ]]; then
        echo "ERROR: wanted Bazel ${requested_version}, got '${version_output}'" >&2
        exit 1
    fi

    echo "Testing local directory"
    (cd "$work" && run_bazel build "--repository_cache=${repository_cache}" :all)
    # Add this if there is unit testing on this directory in the future
    # (cd "$work" && run_bazel test --test_output=errors :all)

    echo "Testing remote usage"
    (
        cd "${work}/test_models"
        run_bazel build "--repository_cache=${repository_cache}" ...
        run_bazel test "--repository_cache=${repository_cache}" --test_output=errors ...
    )

    echo "Test passed with ${version_output}"
    exit 0
}
