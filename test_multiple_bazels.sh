#!/bin/bash

BAZEL_BINARIES=`find ${PATH//:/ } -maxdepth 1 -executable -type f | rev | cut -d '/' -f 1 | rev | grep -e  "^bazel" | sort | uniq | grep -v bazel-real`

for BAZEL in ${BAZEL_BINARIES}; do
    echo "Testing with binary ${BAZEL}, version $(${BAZEL} --version)"
    echo "Testing local directory"
    ${BAZEL} clean
    ${BAZEL} build :all || exit 1
    # Add this if there is unit testing on this directory in the future
    # ${BAZEL} test --test_output=errors :all || exit 1
    echo "Testing remote usage"
    pushd test_models
    ${BAZEL} clean
    ${BAZEL} build ... || exit 1
    ${BAZEL} test --test_output=errors ... || exit 1
    popd
done

echo "Test passed with the following bazel versions"
for BAZEL in ${BAZEL_BINARIES}; do
    echo "- $(${BAZEL} --version)"
done