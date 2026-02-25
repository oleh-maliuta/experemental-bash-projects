import pytest
import os
import shutil
import subprocess
from pathlib import Path

# --- Configuration ---
RUN_SCRIPT = "./run.sh"
TEST_DIR = "./.test_env"

# --- Test Data ---
FILES = [
    "image.JPG",
    "file with spaces.txt",
    "document.pdf",
    "subdir/nested_script.sh",
    "collision_a.txt",
    "collision_b.txt"
]

# --- Fixtures (Setup & Teardown) ---

@pytest.fixture
def setup_test_env():
    """
    Creates the test directory structure and dummy files.
    """
    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)

    os.makedirs(os.path.join(TEST_DIR, "subdir"))

    for file_path in FILES:
        full_path = Path(TEST_DIR, file_path)
        full_path.touch()

    yield

    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)

# --- Helper Functions ---

def run_script(args):
    """Executes the ./run.sh script with provided arguments."""
    cmd = [RUN_SCRIPT] + args
    subprocess.run(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

def assert_exists(file_path):
    """Asserts that a file exists."""
    full_path = os.path.join(TEST_DIR, file_path)
    assert os.path.exists(full_path), f"There is no such file ({full_path})."

def assert_missing(file_path):
    """Asserts that a file does NOT exist."""
    full_path = os.path.join(TEST_DIR, file_path)
    assert not os.path.exists(full_path), f"This file shouldn't exist ({full_path})."

# --- Test Cases ---

def test_prefix_and_suffix(setup_test_env):
    """Test adding prefixes and suffixes."""
    run_script(["-d", TEST_DIR, "-p", "vacation_", "-s", "_v1"])

    assert_exists("vacation_image_v1.JPG")
    assert_exists("vacation_file with spaces_v1.txt")

    assert_exists("subdir/nested_script.sh")


def test_recursive_and_uppercase(setup_test_env):
    """Test recursive mode and uppercase conversion."""
    run_script(["-d", TEST_DIR, "-r", "--upper"])

    assert_exists("IMAGE.JPG")
    assert_missing("image.JPG")

    assert_exists("subdir/NESTED_SCRIPT.sh")


def test_search_and_replace(setup_test_env):
    """Test finding and replacing strings in filenames."""
    run_script(["-d", TEST_DIR, "--find", " ", "--with", "_"])

    assert_exists("file_with_spaces.txt")
    assert_missing("file with spaces.txt")


def test_collision_avoidance(setup_test_env):
    """Test that the script avoids overwriting existing files."""
    run_script(["-d", TEST_DIR, "--find", "collision_a", "--with", "collision_b"])

    assert_exists("collision_a.txt")
    assert_exists("collision_b.txt")


def test_dry_run(setup_test_env):
    """Test dry run mode (-n). No files should change."""
    run_script(["-d", TEST_DIR, "-n", "-p", "FAIL_"])

    assert_exists("image.JPG")

    assert_missing("FAIL_image.JPG")
