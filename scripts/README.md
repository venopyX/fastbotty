# Scripts Directory

This directory contains automation scripts for FastBotty development and release management.

## Available Scripts

### 1. `bump_version.py`

Automated semantic versioning tool. Updates version across all project files.

**Usage:**

```bash
# Bump patch version (1.0.2 -> 1.0.3)
python3 scripts/bump_version.py patch

# Bump minor version (1.0.2 -> 1.1.0)
python3 scripts/bump_version.py minor

# Bump major version (1.0.2 -> 2.0.0)
python3 scripts/bump_version.py major

# Set specific version
python3 scripts/bump_version.py --set 1.2.3
```

**Or use Makefile shortcuts:**

```bash
make bump-patch
make bump-minor
make bump-major
```

**What it does:**

- Updates version in `pyproject.toml`
- Updates version in `fastbotty/__version__.py`
- Updates version in `fastbotty/cli/commands.py`
- Updates version in `fastbotty/server/app.py`

### 2. `release.sh`

Enterprise-grade release automation with validation and rollback capabilities.

**Usage:**

```bash
bash scripts/release.sh <version> "<release_notes_or_file>"

# Example with inline notes
bash scripts/release.sh 1.0.3 "Bug fixes and improvements"

# Example with notes from file (recommended for multi-line notes)
bash scripts/release.sh 1.0.3 RELEASE_NOTES.md
```

**Release Notes File Format:**

```markdown
v1.0.3 - Bug Fix Release

- Fixed link formatting in HTML mode
- Improved error messages
- Updated documentation
```

The first line is used as the release title, subsequent lines become the release notes.

**Or use Makefile:**

```bash
# With inline notes
make release version=1.0.3 notes="Bug fixes and improvements"

# With notes file
make release version=1.0.3 notes=RELEASE_NOTES.md
```

**What it does:**

1. ✅ Validates required tools (python3, build, twine, git)
2. ✅ Checks git status (clean working directory)
3. ✅ Validates version format
4. ✅ Checks if tag already exists
5. ✅ Updates version in all files
6. ✅ Updates CHANGELOG.md with release notes
7. ✅ Runs tests with `python3 -m pytest`
8. ✅ Runs linters with `python3 -m ruff`
9. ✅ Creates git commit
10. ✅ Creates git tag (with title from first line of notes file)
11. ✅ Builds package with `python3 -m build`
12. ✅ Asks for confirmation
13. ✅ Publishes to PyPI with `python3 -m twine upload dist/*`
14. ✅ Pushes to GitHub
15. ✅ Creates GitHub release (if `gh` CLI available)

**Features:**

- Automatic rollback on failure
- Git status validation
- Tool dependency checking
- Interactive confirmations
- Colored output
- Comprehensive error messages
- Support for release notes from file

### 3. `test_release.sh`

Test package build and upload to TestPyPI before production release.

**Usage:**

```bash
bash scripts/test_release.sh
```

**Or use Makefile:**

```bash
make test-release
```

**What it does:**

1. Runs all tests
2. Builds package
3. Uploads to TestPyPI
4. Provides installation command for testing

**Requirements:**

- TestPyPI account and API token
- Get token at: https://test.pypi.org/manage/account/token/

### 4. `setup_dev.sh`

Setup local development environment.

**Usage:**

```bash
bash scripts/setup_dev.sh
```

**Or use Makefile:**

```bash
make install
```

**What it does:**

- Checks Python version (requires 3.10+)
- Creates virtual environment (.venv)
- Installs all dependencies from requirements-dev.txt
- Sets up development tools

**First-time setup:**

```bash
# Just run setup - it will create a venv and install everything
make install

# Or manually:
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

## Workflow Examples

### Development Workflow

```bash
# 1. Setup environment
make install

# 2. Make changes to code
# ...

# 3. Run checks
make format   # Format code
make lint     # Check code quality
make test     # Run tests

# Or run all at once
make check
```

### Release Workflow

```bash
# 1. Run pre-release checks
make pre-release

# 2. Bump version
make bump-patch  # or bump-minor, bump-major

# 3. Test on TestPyPI (optional)
make test-release

# 4. Release to production
make release version=1.0.3 notes="Bug fixes and improvements"
```

### Quick Patch Release

```bash
# For urgent bug fixes
make bump-patch
make release version=$(make version | tail -1) notes="Critical bug fix"
```

## Environment Variables

Scripts may use these environment variables:

- `GITHUB_TOKEN` - For GitHub release creation (optional, falls back to `gh` CLI)
- `TWINE_USERNAME` - PyPI username (usually `__token__`)
- `TWINE_PASSWORD` - PyPI authentication token (starts with `pypi-`)
- `TWINE_REPOSITORY_URL` - Custom PyPI repository URL (optional)

## Requirements

- **Python 3.10+**
- **build** - Python build system (`pip install build`)
- **twine** - PyPI upload tool (`pip install twine`)
- **Git** - Version control
- **gh CLI** (optional) - For GitHub release creation

All development tools can be installed with:

```bash
pip install -r requirements-dev.txt
```

## Troubleshooting

### "build module not found"

```bash
pip install -r requirements-dev.txt
# Or install individually:
pip install build twine
```

### "Tests failed"

```bash
make test  # Run tests to see what's failing
```

### "Git working directory not clean"

```bash
git status
git add .
git commit -m "Your changes"
```

### "Tag already exists"

```bash
# Delete tag locally and remotely
git tag -d v1.0.3
git push origin :refs/tags/v1.0.3
```

## Script Maintenance

These scripts are designed to be:

- **Self-contained** - No external dependencies beyond standard tools
- **Cross-platform** - Work on Linux, macOS, and WSL
- **Well-documented** - Clear error messages and help text
- **Fail-safe** - Validate before executing, rollback on error

When modifying scripts:

1. Test on a clean clone
2. Ensure error handling works
3. Update this README
4. Test rollback scenarios

## See Also

- [Makefile](../Makefile) - High-level automation commands
- [Contributing Guide](../docs/CONTRIBUTING.md) - Development guidelines
- [Release Process](../docs/RELEASE_PROCESS.md) - Detailed release documentation
