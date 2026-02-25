import pytest
import os
import shutil
import subprocess
from pathlib import Path

# --- Configuration ---
RUN_SCRIPT = "./run.sh"
TEST_DIR = "./.test_env"

# --- Test Data ---
IMAGES = ["image1.jpg", "image2.png", "image3.svg"]
VIDEOS = ["video1.mp4", "video2.avi", "video3.mov"]
DOCUMENTS = ["document1.doc", "document2.docx", "document3.pdf"]
OTHERS = ["other1.c", "other2.asm", "other3.cs"]

# --- Fixtures (Setup & Teardown) ---

@pytest.fixture
def setup_test_env():
    """
    Creates the test directory and dummy files before each test.
    Cleans up after the test is done.
    """
    # Setup
    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)

    os.makedirs(TEST_DIR)

    ALL_FILES = IMAGES + VIDEOS + DOCUMENTS + OTHERS
    for file_name in ALL_FILES:
        Path(TEST_DIR, file_name).touch()

    yield

    # Teardown
    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)

# --- Helper Functions ---

def run_script(args):
    """Executes the 'RUN_SCRIPT' with provided arguments."""
    cmd = [RUN_SCRIPT] + args
    result = subprocess.run(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    return result

def assert_files_exist(directory, file_list):
    """Asserts that all files in the list exist in the given directory."""
    for file_name in file_list:
        file_path = os.path.join(directory, file_name)
        assert os.path.exists(file_path), f"There is no such file ({file_path})."

def assert_file_missing(file_path):
    """Asserts that a specific file does NOT exist."""
    assert not os.path.exists(file_path), f"This file shouldn't exist ({file_path})."

# --- Test Cases ---

def test_basic_organization(setup_test_env):
    """Test standard categorization logic."""
    run_script([TEST_DIR])

    assert_files_exist(os.path.join(TEST_DIR, "Images"), IMAGES)
    assert_files_exist(os.path.join(TEST_DIR, "Videos"), VIDEOS)
    assert_files_exist(os.path.join(TEST_DIR, "Documents"), DOCUMENTS)
    assert_files_exist(os.path.join(TEST_DIR, "Others"), OTHERS)

    assert_file_missing(os.path.join(TEST_DIR, "Images", "video1.mp4"))


def test_category_excluding(setup_test_env):
    """Test excluding categories logic (-e 'Images,Documents')."""
    run_script([TEST_DIR, "-e", "Images,Documents"])

    assert_files_exist(TEST_DIR, IMAGES)
    assert_files_exist(TEST_DIR, DOCUMENTS)

    assert_files_exist(os.path.join(TEST_DIR, "Videos"), VIDEOS)
    assert_files_exist(os.path.join(TEST_DIR, "Others"), OTHERS)

    assert_file_missing(os.path.join(TEST_DIR, "video1.mp4"))


def test_others_dir_excluding(setup_test_env):
    """Test excluding categories logic (-e 'Videos,Others')."""
    run_script([TEST_DIR, "-e", "Videos,Others"])

    assert_files_exist(os.path.join(TEST_DIR, "Images"), IMAGES)
    assert_files_exist(os.path.join(TEST_DIR, "Documents"), DOCUMENTS)

    assert_files_exist(TEST_DIR, VIDEOS)
    assert_files_exist(TEST_DIR, OTHERS)

    assert_file_missing(os.path.join(TEST_DIR, "Others", "video1.mp4"))


def test_extension_ignoring(setup_test_env):
    """Test ignoring specific extensions (-i 'docx,c,png')."""
    run_script([TEST_DIR, "-i", "docx,c,png"])

    ignored_files = ['document2.docx', 'other1.c', 'image2.png']
    assert_files_exist(TEST_DIR, ignored_files)

    assert_file_missing(os.path.join(TEST_DIR, "document1.doc"))


def test_dry_run(setup_test_env):
    """Test dry run mode (-n). Nothing should move."""
    run_script([TEST_DIR, "-n", "-i", "cs,mp4"])

    assert_files_exist(TEST_DIR, IMAGES)
    assert_files_exist(TEST_DIR, VIDEOS)
    assert_files_exist(TEST_DIR, DOCUMENTS)
    assert_files_exist(TEST_DIR, OTHERS)
