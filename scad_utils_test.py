"""Tests for scad_utils.diff_stls, which needs a real OpenSCAD to run.

Run directly (python3 scad_utils_test.py) or through Bazel (//:scad_utils_test).
"""
import os
import re
import tempfile
from typing import Callable, List, Tuple

import scad_utils

OPENSCAD = "openscad"
TOLERANCE = 1e-3


def _render(directory: str, name: str, scad_code: str) -> str:
    """Renders scad_code to <directory>/<name>.stl and returns that path."""
    stl = os.path.join(directory, name + ".stl")
    return_code, stderr = scad_utils.render_stl(
        scad_code, os.path.join(directory, name + ".scad"), stl, OPENSCAD)
    assert return_code == 0, stderr
    return stl


def _nudge(stl: str, name: str, delta: float) -> str:
    """Copies an ASCII STL with every coordinate moved by delta, mimicking a golden file whose
    digits differ slightly from what another OpenSCAD version renders."""
    nudged = os.path.join(os.path.dirname(stl), name + ".stl")
    with open(stl) as src, open(nudged, "w") as dst:
        for line in src:
            if "vertex" in line:
                line = re.sub(r"-?\d+(\.\d+)?(e[-+]?\d+)?",
                              lambda m: repr(float(m.group(0)) + delta), line)
            dst.write(line)
    return nudged


def _diff(directory: str, expected: str, actual: str) -> Tuple[bool, str, str, str]:
    """Runs diff_stls and returns (different, new_parts, missing_parts, diff) file paths."""
    new_parts = os.path.join(directory, "new_parts.stl")
    missing_parts = os.path.join(directory, "missing_parts.stl")
    diff = os.path.join(directory, "diff.stl")
    different = scad_utils.diff_stls(
        expected, actual, os.path.join(directory, "diff.scad"), new_parts, missing_parts, diff,
        TOLERANCE, OPENSCAD)
    return different, new_parts, missing_parts, diff


CUBE = "cube([10, 20, 30]);"


def test_contract_identical_stls_are_equal() -> None:
    """Rendering the same shape twice reports no difference and writes no debug files."""
    with tempfile.TemporaryDirectory() as d:
        a = _render(d, "a", CUBE)
        different, new_parts, missing_parts, diff = _diff(d, a, a)
        assert not different
        assert not any(os.path.exists(f) for f in (new_parts, missing_parts, diff))


def test_contract_difference_within_tolerance_is_equal() -> None:
    """A copy whose coordinates differ by 1e-6, well below the tolerance, is reported equal."""
    with tempfile.TemporaryDirectory() as d:
        a = _render(d, "a", CUBE)
        for delta in (1e-6, -1e-6):
            assert not _diff(d, _nudge(a, "b", delta), a)[0]
            assert not _diff(d, a, _nudge(a, "c", delta))[0]


def test_contract_larger_object_reports_new_parts() -> None:
    """An actual STL 0.01 larger than the expected one is different, with new parts only."""
    with tempfile.TemporaryDirectory() as d:
        expected = _render(d, "expected", CUBE)
        actual = _render(d, "actual", "cube([10.01, 20, 30]);")
        different, new_parts, missing_parts, diff = _diff(d, expected, actual)
        assert different
        assert os.path.exists(new_parts)
        assert not os.path.exists(missing_parts)
        assert os.path.exists(diff)


def test_contract_smaller_object_reports_missing_parts() -> None:
    """An actual STL 0.01 smaller than the expected one is different, with missing parts only."""
    with tempfile.TemporaryDirectory() as d:
        expected = _render(d, "expected", CUBE)
        actual = _render(d, "actual", "cube([10, 20, 29.99]);")
        different, new_parts, missing_parts, diff = _diff(d, expected, actual)
        assert different
        assert not os.path.exists(new_parts)
        assert os.path.exists(missing_parts)
        assert os.path.exists(diff)


def test_contract_moved_and_resized_object_reports_both() -> None:
    """A shifted object has parts both new and missing, and diff.stl combines the two."""
    with tempfile.TemporaryDirectory() as d:
        expected = _render(d, "expected", CUBE)
        actual = _render(d, "actual", "translate([0.5, 0, 0]) cube([10, 20, 30]);")
        different, new_parts, missing_parts, diff = _diff(d, expected, actual)
        assert different
        assert all(os.path.exists(f) for f in (new_parts, missing_parts, diff))


def test_contract_debug_stls_ignore_differences_within_tolerance() -> None:
    """When a real difference exists, the debug STLs hold only it, not the rounding noise."""
    with tempfile.TemporaryDirectory() as d:
        expected = _nudge(_render(d, "base", CUBE), "expected", 1e-6)
        actual = _render(d, "actual", "cube([10.01, 20, 30]);")
        different, new_parts, _, _ = _diff(d, expected, actual)
        assert different
        # What is left is the part of the 0.01 slab that is beyond the tolerance. Nothing may
        # remain on the original body, where the 1e-6 of noise is.
        xs = [float(x) for x in re.findall(r"vertex (\S+)", open(new_parts).read())]
        assert xs and min(xs) >= 10 + TOLERANCE / 2, min(xs)


if __name__ == "__main__":
    tests: List[Callable[[], None]] = [
        f for name, f in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
        print("PASSED", test.__name__)
    print("%d tests passed" % len(tests))
